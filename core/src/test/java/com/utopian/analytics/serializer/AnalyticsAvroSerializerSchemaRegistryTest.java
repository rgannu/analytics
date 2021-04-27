package com.utopian.analytics.serializer;

import static org.assertj.core.api.Assertions.assertThat;

import com.google.common.collect.ImmutableMap;
import com.utopian.analytics.util.SchemaRegistryUtil;
import io.confluent.kafka.schemaregistry.client.CachedSchemaRegistryClient;
import io.confluent.kafka.schemaregistry.client.SchemaRegistryClient;
import io.confluent.kafka.schemaregistry.client.rest.exceptions.RestClientException;
import io.confluent.kafka.serializers.AbstractKafkaSchemaSerDeConfig;
import io.confluent.kafka.serializers.KafkaAvroDeserializer;
import io.confluent.kafka.serializers.KafkaAvroDeserializerConfig;
import io.confluent.kafka.serializers.KafkaAvroSerializer;
import java.io.IOException;
import org.apache.avro.generic.IndexedRecord;
import org.junit.Ignore;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

class AnalyticsAvroSerializerSchemaRegistryTest {

    private final static String TEST_TABLE_TOPIC = "dbanalytics.services.test_table";
    private static final String SIMPLE_TEST_TABLE_TOPIC = "dbanalytics.services.simple_table";
    private static final String SCHEMA_REGISTRY_HOST = "172.22.0.5";
    private static final int SCHEMA_REGISTRY_PORT = 18081;
    public static final int IDENTITY_MAP_CAPACITY = 5;

    private static SchemaRegistryClient schemaRegistry;
    private static KafkaAvroSerializer avroSerializer;
    private static KafkaAvroDeserializer avroDeserializer;
    private static KafkaAvroDeserializer specificAvroDeserializer;

    public static final String SIMPLE_TABLE_JSON_STR = "{\n"
        + "   \"op\":\"c\",\n"
        + "   \"ts_ms\":{\n"
        + "      \"long\":1595307414748\n"
        + "   }\n"
        + "}";
    public static final String TEST_TABLE_JSON_STR = "{\n"
        + "   \"before\":null,\n"
        + "   \"after\":{\n"
        + "      \"dbanalytics.services.test_table.Value\":{\n"
        + "         \"id\":6,\n"
        + "         \"uuid\":\"1cbbdfd8-3d2e-4064-99b3-e3ec532982ad\",\n"
        + "         \"version\":0\n"
        + "      }\n"
        + "   },\n"
        + "   \"source\":{\n"
        + "      \"version\":\"1.2.0.Beta2\",\n"
        + "      \"connector\":\"postgresql\",\n"
        + "      \"name\":\"dbanalytics\",\n"
        + "      \"ts_ms\":1595307414616,\n"
        + "      \"snapshot\":{\n"
        + "         \"string\":\"false\"\n"
        + "      },\n"
        + "      \"db\":\"services\",\n"
        + "      \"schema\":\"services\",\n"
        + "      \"table\":\"test_table\",\n"
        + "      \"txId\":{\n"
        + "         \"long\":606\n"
        + "      },\n"
        + "      \"lsn\":{\n"
        + "         \"long\":44933328\n"
        + "      },\n"
        + "      \"xmin\":null\n"
        + "   },\n"
        + "   \"op\":\"c\",\n"
        + "   \"ts_ms\":{\n"
        + "      \"long\":1595307414748\n"
        + "   },\n"
        + "   \"transaction\":null\n"
        + "}";
    public static final String SUBJECT_TEST_TABLE_KEY = "dbanalytics.services.test_table-key";
    public static final String SUBJECT_TEST_TABLE_VALUE = "dbanalytics.services.test_table-value";

    @BeforeAll
    public static void setup() throws IOException, RestClientException {
        String baseUrl = "http://" + SCHEMA_REGISTRY_HOST + ":" + SCHEMA_REGISTRY_PORT;
        schemaRegistry = new CachedSchemaRegistryClient(baseUrl, IDENTITY_MAP_CAPACITY);

        final ImmutableMap<String, Object> configs = ImmutableMap.of(
            AbstractKafkaSchemaSerDeConfig.SCHEMA_REGISTRY_URL_CONFIG, baseUrl
        );
        avroSerializer = new KafkaAvroSerializer(schemaRegistry, configs);
        avroSerializer.register(SUBJECT_TEST_TABLE_KEY,
            SchemaRegistryUtil.avroSchema(schemaRegistry, SUBJECT_TEST_TABLE_KEY));
        avroSerializer.register(SUBJECT_TEST_TABLE_VALUE,
            SchemaRegistryUtil.avroSchema(schemaRegistry, SUBJECT_TEST_TABLE_VALUE));
        avroDeserializer = new KafkaAvroDeserializer(schemaRegistry, configs);

        final ImmutableMap<String, Object> specificDeserializerProps =
            ImmutableMap.of(
                KafkaAvroDeserializerConfig.AUTO_REGISTER_SCHEMAS, true,
                KafkaAvroDeserializerConfig.SCHEMA_REGISTRY_URL_CONFIG, baseUrl,
                KafkaAvroDeserializerConfig.SPECIFIC_AVRO_READER_CONFIG, "true"
            );

        specificAvroDeserializer = new KafkaAvroDeserializer(schemaRegistry,
            specificDeserializerProps);
    }

    @Ignore
    public void testKafkaEnvelopeAvroSerializer() throws Exception {
        IndexedRecord avroRecord = SchemaRegistryUtil
            .fromJsonToAvro(schemaRegistry, TEST_TABLE_JSON_STR,
                SUBJECT_TEST_TABLE_VALUE);
        byte[] bytes = avroSerializer.serialize(TEST_TABLE_TOPIC, avroRecord);
        assertThat(avroDeserializer.deserialize(TEST_TABLE_TOPIC, bytes))
            .isEqualTo(avroRecord);
    }

    @Ignore
    public void testKafkaAvroSerializerSpecificRecordPrimitive() throws Exception {
        IndexedRecord avroRecord = SchemaRegistryUtil.fromJsonToAvro(SIMPLE_TABLE_JSON_STR,
            dbanalytics.services.simple_table.Envelope.getClassSchema());
        byte[] bytes = avroSerializer.serialize(SIMPLE_TEST_TABLE_TOPIC, avroRecord);

        Object obj = specificAvroDeserializer.deserialize(SIMPLE_TEST_TABLE_TOPIC, bytes);
        assertThat(obj)
            .isInstanceOf(dbanalytics.services.simple_table.Envelope.class);
    }

    @Ignore
    public void testKafkaAvroSerializerSpecificRecordComplex() throws Exception {
        IndexedRecord avroRecord = SchemaRegistryUtil
            .fromJsonToAvro(schemaRegistry, TEST_TABLE_JSON_STR,
                SUBJECT_TEST_TABLE_VALUE
            );
        byte[] bytes = avroSerializer.serialize(TEST_TABLE_TOPIC, avroRecord);
        assertThat(avroDeserializer.deserialize(TEST_TABLE_TOPIC, bytes))
            .isEqualTo(avroRecord);

        Object obj = specificAvroDeserializer.deserialize(TEST_TABLE_TOPIC, bytes);
        assertThat(obj)
            .isInstanceOf(dbanalytics.services.test_table.Envelope.class);
    }

}
