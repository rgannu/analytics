package com.utopian.analytics.amqp;

import static com.utopian.analytics.util.SchemaRegistryUtil.avroSchema;
import static java.util.Arrays.asList;
import static org.assertj.core.api.Assertions.assertThat;

import com.google.common.collect.ImmutableMap;
import com.rabbitmq.client.AMQP;
import com.rabbitmq.client.Channel;
import com.rabbitmq.client.Connection;
import com.rabbitmq.client.ConnectionFactory;
import com.rabbitmq.client.DefaultConsumer;
import com.rabbitmq.client.Envelope;
import io.confluent.kafka.schemaregistry.client.CachedSchemaRegistryClient;
import io.confluent.kafka.schemaregistry.client.SchemaRegistryClient;
import io.confluent.kafka.schemaregistry.client.rest.exceptions.RestClientException;
import io.confluent.kafka.serializers.AbstractKafkaSchemaSerDeConfig;
import io.confluent.kafka.serializers.KafkaAvroDeserializer;
import io.confluent.kafka.serializers.KafkaAvroDeserializerConfig;
import io.confluent.kafka.serializers.KafkaAvroSerializer;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import joptsimple.AbstractOptionSpec;
import joptsimple.ArgumentAcceptingOptionSpec;
import joptsimple.OptionParser;
import joptsimple.OptionSet;
import joptsimple.util.RegexMatcher;
import org.apache.avro.generic.GenericData.Record;

class Consumer {

    private static final String ANALYTICS_QUEUE_NAME = "analytics";
    private static final String SCHEMA_REGISTRY_QUEUE_NAME = "schema-registry";

    private static final String LOCALHOST = "localhost";
    private static final String USER_NAME = "guest";
    private static final String PASSWORD = "guest";
    private final Channel channel;
    private Connection connection = null;
    private final String replyQueueName;
    private final String requestQueueName;

    private final static String TEST_TABLE_TOPIC = "dbanalytics.services.test_table";
    public static final String SUBJECT_TEST_TABLE_KEY = "dbanalytics.services.test_table-key";
    public static final String SUBJECT_TEST_TABLE_VALUE = "dbanalytics.services.test_table-value";

    public static final int IDENTITY_MAP_CAPACITY = 5;

    private static SchemaRegistryClient schemaRegistry;
    private static KafkaAvroSerializer avroSerializer;
    private static KafkaAvroDeserializer avroDeserializer;
    private static KafkaAvroDeserializer specificAvroDeserializer;

    public Consumer(String requestQueueName, String baseUrl) throws Exception {
        ConnectionFactory factory = new ConnectionFactory();
        factory.setHost(LOCALHOST);
        factory.setUsername(USER_NAME);
        factory.setPassword(PASSWORD);

        connection = factory.newConnection();

        this.requestQueueName = requestQueueName;
        connection = factory.newConnection();
        channel = connection.createChannel();

        replyQueueName = channel.queueDeclare().getQueue();
        initSchemaRegistry(baseUrl);
    }

    private void initSchemaRegistry(String baseUrl) throws IOException, RestClientException {
        schemaRegistry = new CachedSchemaRegistryClient(baseUrl, IDENTITY_MAP_CAPACITY);

        final ImmutableMap<String, Object> configs = ImmutableMap.of(
            AbstractKafkaSchemaSerDeConfig.SCHEMA_REGISTRY_URL_CONFIG, baseUrl
        );
        avroSerializer = new KafkaAvroSerializer(schemaRegistry, configs);
        avroSerializer.register(SUBJECT_TEST_TABLE_KEY,
            avroSchema(schemaRegistry, SUBJECT_TEST_TABLE_KEY));
        avroSerializer.register(SUBJECT_TEST_TABLE_VALUE,
            avroSchema(schemaRegistry, SUBJECT_TEST_TABLE_VALUE));
        avroDeserializer = new KafkaAvroDeserializer(schemaRegistry, configs);

        final ImmutableMap<String, Object> specificDeserializerProps =
            ImmutableMap.of(
                KafkaAvroDeserializerConfig.AUTO_REGISTER_SCHEMAS, true,
                KafkaAvroDeserializerConfig.SCHEMA_REGISTRY_URL_CONFIG, baseUrl,
                KafkaAvroDeserializerConfig.SCHEMA_REFLECTION_CONFIG, true,
                KafkaAvroDeserializerConfig.SPECIFIC_AVRO_READER_CONFIG, "true"
            );

        specificAvroDeserializer = new KafkaAvroDeserializer(schemaRegistry,
            specificDeserializerProps);
    }

    public Thread receive() {
        Thread t = new Thread(() -> {
            try {
                System.out.println("Processing thread");
                Channel channel = this.connection.createChannel();
                // When RabbitMQ quits or crashes it will forget the queues and messages
                // unless set durable = true
                boolean durable = false;
                String queue = channel
                    .queueDeclare(this.requestQueueName, durable, false, false, null)
                    .getQueue();

                com.rabbitmq.client.Consumer consumer = new DefaultConsumer(channel) {
                    @Override
                    public void handleDelivery(String consumerTag, Envelope envelope,
                        AMQP.BasicProperties properties, byte[] body) {
                        try {
                            String message = new String(body, StandardCharsets.UTF_8);

                            Map<String, Object> headers = properties.getHeaders();
                            Object recordKey = headers.get("camel.kafka.connector.record.key");
                            if (null != recordKey) {
                                System.out.println("Record key: " + recordKey.toString());
                                System.out.println("Received:" + message);
                            } else {
                                // ToDo: Need to determine based on the header property decode properly
                                Object obj = avroDeserializer
                                    .deserialize(TEST_TABLE_TOPIC, body,
                                        dbanalytics.services.test_table.Envelope.getClassSchema());
                                System.out.println("Decoded AVRO message:" + obj);
                                assertThat(obj).isInstanceOf(Record.class);

                                Object specificDeserialized = specificAvroDeserializer
                                    .deserialize(TEST_TABLE_TOPIC, body,
                                        dbanalytics.services.test_table.Envelope.getClassSchema());
                                System.out.println(
                                    "Decoded Specific AVRO message:" + specificDeserialized);
                                assertThat(specificDeserialized)
                                    .isInstanceOf(dbanalytics.services.test_table.Envelope.class);
                            }
                        } catch (Exception e) {
                            System.out.println("Error in decoding the AVRO message");
                            e.printStackTrace();
                            throw e;
                        }
                    }
                };

                // auto acknowledgment is true
                // if false, will result in messages_unacknowledged
                // `rabbitmqctl list_queues name messages_ready messages_unacknowledged`
                channel.basicConsume(queue, true, consumer);

                while (!Thread.currentThread().isInterrupted()) {
                    Thread.sleep(5000);
                }
            } catch (Exception e) {
                Thread.currentThread().interrupt();
            } finally {
                try {
                    channel.close();
                    connection.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

        });

        t.start();
        return t;
    }

    public static void main(String[] args) {
        OptionParser optionParser = new OptionParser();
        try {
            ArgumentAcceptingOptionSpec<String> baseUrlOpt = optionParser
                .acceptsAll(asList("u", "url")).withRequiredArg().ofType(String.class)
                .describedAs("Schema Registry Base URL like http://<schema-registry-host>:<port>")
                .withValuesConvertedBy(RegexMatcher.regex("^(http|https)\\:\\/\\/.*:\\d{4,6}"))
                .defaultsTo("http://172.22.0.6:18081");

            AbstractOptionSpec<Void> helpOpt = optionParser
                .acceptsAll(asList("h", "?"), "show help").forHelp();

            optionParser.printHelpOn(System.out);

            OptionSet options = optionParser.parse(args);
            if (options.has(helpOpt)) {
                System.exit(0);
            }
            String baseUrl = options.valueOf(baseUrlOpt);

            Thread receiver1 = new Consumer(ANALYTICS_QUEUE_NAME, baseUrl).receive();
            Thread receiver2 = new Consumer(SCHEMA_REGISTRY_QUEUE_NAME, baseUrl).receive();
            receiver1.join();
            receiver2.join();
            System.out.println("All threads joined!!!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}