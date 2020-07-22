package com.utopian.analytics.serializer;

import static com.utopian.analytics.util.SchemaRegistryUtil.fromJsonToAvro;
import static org.assertj.core.api.Assertions.assertThat;

import com.google.common.collect.ImmutableMap;
import dbanalytics.services.test_table.Envelope;
import io.confluent.kafka.schemaregistry.client.MockSchemaRegistryClient;
import io.confluent.kafka.schemaregistry.client.SchemaRegistryClient;
import io.confluent.kafka.serializers.AbstractKafkaSchemaSerDeConfig;
import io.confluent.kafka.serializers.KafkaAvroDeserializer;
import io.confluent.kafka.serializers.KafkaAvroDeserializerConfig;
import io.confluent.kafka.serializers.KafkaAvroSerializer;
import org.apache.avro.Schema;
import org.apache.avro.generic.IndexedRecord;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

class AnalyticsAvroSerializerTest {

    private final static String TEST_TABLE_TOPIC = "dbanalytics.services.test_table";
    private static final String SIMPLE_TEST_TABLE_TOPIC = "dbanalytics.services.simple_table";

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

    @BeforeAll
    public static void setup() {
        final SchemaRegistryClient schemaRegistry = new MockSchemaRegistryClient();
        final ImmutableMap<String, Object> configs = ImmutableMap.of(
            AbstractKafkaSchemaSerDeConfig.AUTO_REGISTER_SCHEMAS, true,
            AbstractKafkaSchemaSerDeConfig.SCHEMA_REGISTRY_URL_CONFIG, ""
        );
        avroSerializer = new KafkaAvroSerializer(schemaRegistry, configs);
        avroDeserializer = new KafkaAvroDeserializer(schemaRegistry, configs);
        final ImmutableMap<String, Object> specificDeserializerProps =
            ImmutableMap.of(
                KafkaAvroDeserializerConfig.AUTO_REGISTER_SCHEMAS, true,
                KafkaAvroDeserializerConfig.SCHEMA_REGISTRY_URL_CONFIG, "",
                KafkaAvroDeserializerConfig.SPECIFIC_AVRO_READER_CONFIG, "true"
            );

        specificAvroDeserializer = new KafkaAvroDeserializer(schemaRegistry,
            specificDeserializerProps);
    }

    @Test
    public void testKafkaEnvelopeAvroSerializer() throws Exception {
        byte[] bytes;
        Schema schema = Envelope.getClassSchema();
        IndexedRecord avroRecord = fromJsonToAvro(TEST_TABLE_JSON_STR, schema);
        bytes = avroSerializer.serialize(TEST_TABLE_TOPIC, avroRecord);
        assertThat(avroDeserializer.deserialize(TEST_TABLE_TOPIC, bytes))
            .isEqualTo(avroRecord);
    }

    @Test
    public void testKafkaAvroSerializerSpecificRecordPrimitive() throws Exception {
        IndexedRecord avroRecord = fromJsonToAvro(SIMPLE_TABLE_JSON_STR,
            dbanalytics.services.simple_table.Envelope.getClassSchema());
        byte[] bytes = avroSerializer.serialize(SIMPLE_TEST_TABLE_TOPIC, avroRecord);

        Object obj = specificAvroDeserializer.deserialize(SIMPLE_TEST_TABLE_TOPIC, bytes);
        assertThat(obj)
            .isInstanceOf(dbanalytics.services.simple_table.Envelope.class);
    }

    @Test
    public void testKafkaAvroSerializerSpecificRecordComplex() throws Exception {
        Schema schema = Envelope.getClassSchema();
        IndexedRecord avroRecord = fromJsonToAvro(TEST_TABLE_JSON_STR, schema);
        byte[] bytes = avroSerializer.serialize(TEST_TABLE_TOPIC, avroRecord);

        Object obj = specificAvroDeserializer.deserialize(TEST_TABLE_TOPIC, bytes);
        assertThat(obj)
            .isInstanceOf(dbanalytics.services.test_table.Envelope.class);
    }

}
