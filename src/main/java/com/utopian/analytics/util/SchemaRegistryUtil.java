package com.utopian.analytics.util;

import static org.assertj.core.api.Assertions.assertThat;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.confluent.kafka.schemaregistry.avro.AvroSchema;
import io.confluent.kafka.schemaregistry.client.SchemaRegistryClient;
import io.confluent.kafka.schemaregistry.client.rest.Versions;
import io.confluent.kafka.schemaregistry.client.rest.entities.Config;
import io.confluent.kafka.schemaregistry.client.rest.entities.Schema;
import io.confluent.kafka.schemaregistry.client.rest.exceptions.RestClientException;
import java.io.IOException;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import org.apache.avro.Schema.Parser;
import org.apache.avro.generic.GenericData.Record;
import org.apache.avro.generic.GenericDatumReader;
import org.apache.avro.generic.IndexedRecord;
import org.apache.avro.io.DatumReader;
import org.apache.avro.io.Decoder;
import org.apache.avro.io.DecoderFactory;
import org.jetbrains.annotations.NotNull;
import org.testcontainers.shaded.okhttp3.MediaType;
import org.testcontainers.shaded.okhttp3.OkHttpClient;
import org.testcontainers.shaded.okhttp3.Request;

public class SchemaRegistryUtil {

    private static final TypeReference<Config> GET_CONFIG_RESPONSE_TYPE =
        new TypeReference<Config>() {
        };
    private static final TypeReference<List<String>> ALL_TOPICS_RESPONSE_TYPE =
        new TypeReference<List<String>>() {
        };
    private static final TypeReference<List<String>> GET_SCHEMA_TYPES_TYPE =
        new com.fasterxml.jackson.core.type.TypeReference<List<String>>() {
        };
    private static final TypeReference<Schema> GET_SCHEMA_BY_VERSION_RESPONSE_TYPE =
        new TypeReference<Schema>() {
        };
    private static final TypeReference<List<Integer>> ALL_VERSIONS_RESPONSE_TYPE =
        new TypeReference<List<Integer>>() {
        };

    private final static MediaType SCHEMA_CONTENT =
        MediaType.parse("application/vnd.schemaregistry.v1+json");
    public static final ObjectMapper JSON_DESERIALIZER = new ObjectMapper();
    private final OkHttpClient client = new OkHttpClient();
    private final String baseUrl;
    private static final Map<String, String> DEFAULT_REQUEST_PROPERTIES;

    static {
        DEFAULT_REQUEST_PROPERTIES =
            Collections.singletonMap("Content-Type", Versions.SCHEMA_REGISTRY_V1_JSON_WEIGHTED);
    }

    public SchemaRegistryUtil(String hostname, int port) {
        this.baseUrl = "http://" + hostname + ":" + port;
    }

    @NotNull
    public static AvroSchema avroSchema(SchemaRegistryClient schemaRegistry, String subject)
        throws IOException, RestClientException {
        return new AvroSchema(schemaRegistry.getLatestSchemaMetadata(subject).getSchema());
    }

    public static IndexedRecord fromJsonToAvro(String json, org.apache.avro.Schema schema)
        throws IOException {
        DecoderFactory decoderFactory = new DecoderFactory();
        Decoder decoder = decoderFactory.jsonDecoder(schema, json);
        DatumReader<Record> reader = new GenericDatumReader<>(schema);
        return reader.read(null, decoder);
    }

    public static IndexedRecord fromJsonToAvro(SchemaRegistryClient schemaRegistry, String json,
        String subject)
        throws IOException, RestClientException {
        return fromJsonToAvro(json, new Parser().parse(schemaRegistry
            .getLatestSchemaMetadata(subject).getSchema()));
    }

    public String getBaseUrl() {
        return baseUrl;
    }

    public static void main(String[] args) throws IOException {
        String hostname;
        int port;

        if (args.length == 0) {
            hostname = "localhost";
            port = 18081;
        } else {
            if (args.length != 2) {
                System.out.println("Usage: SchemaMain <hostname> <port>");
                System.exit(1);
            }
            hostname = args[0];
            port = Integer.parseInt(args[1]);
        }

        SchemaRegistryUtil schemaRegistryUtil = new SchemaRegistryUtil(hostname, port);
        assertThat(schemaRegistryUtil.getAllTopics())
            .containsExactlyInAnyOrder("dbanalytics.services.test_table-key",
                "dbanalytics.services.test_table-value");
        assertThat(schemaRegistryUtil.getConfig().getCompatibilityLevel())
            .isEqualTo("BACKWARD");
        assertThat(schemaRegistryUtil.getAllVersions("dbanalytics.services.test_table-key"))
            .contains(1);
        assertThat(schemaRegistryUtil.getAllVersions("dbanalytics.services.test_table-value"))
            .contains(1);
        assertThat(schemaRegistryUtil.getId(1).getSchema())
            .isNotEmpty();
        assertThat(schemaRegistryUtil.getSchemaTypes())
            .containsExactlyInAnyOrder("JSON", "PROTOBUF", "AVRO");
        assertThat(schemaRegistryUtil.getVersion("dbanalytics.services.test_table-key", 1))
            .isEqualTo(schemaRegistryUtil.getLatestVersion("dbanalytics.services.test_table-key"));
        assertThat(schemaRegistryUtil.getVersion("dbanalytics.services.test_table-value", 1))
            .isEqualTo(schemaRegistryUtil.getLatestVersion("dbanalytics.services.test_table-value"));
    }

    public Schema getId(int id) throws IOException {
        String requestUrl = String.format("/schemas/ids/%d", id);
        return getResponse(requestUrl, GET_SCHEMA_BY_VERSION_RESPONSE_TYPE);
    }

    public List<String> getSchemaTypes() throws IOException {
        return getResponse("/schemas/types", GET_SCHEMA_TYPES_TYPE);
    }

    public List<String> getAllTopics() throws IOException {
        return getResponse("/subjects", ALL_TOPICS_RESPONSE_TYPE);
    }

    public Config getConfig() throws IOException {
        return getResponse("/config", GET_CONFIG_RESPONSE_TYPE);
    }

    public List<Integer> getAllVersions(String subject) throws IOException {
        String requestUrl = String.format("/subjects/%s/versions/", subject);
        return getResponse(requestUrl, ALL_VERSIONS_RESPONSE_TYPE);
    }

    public Schema getVersion(String subject, int version) throws IOException {
        String requestUrl = String.format("/subjects/%s/versions/%d", subject, version);
        return getResponse(requestUrl, GET_SCHEMA_BY_VERSION_RESPONSE_TYPE);
    }

    public Schema getLatestVersion(String subject) throws IOException {
        String requestUrl = String.format("/subjects/%s/versions/latest/", subject);
        return getResponse(requestUrl, GET_SCHEMA_BY_VERSION_RESPONSE_TYPE);
    }

    private <T> T getResponse(String requestUrl, TypeReference<T> responseFormat)
        throws IOException {
        Request request = new Request.Builder()
            .url(String.format("%s%s", baseUrl, requestUrl))
            .build();
        String strResponse = client.newCall(request).execute().body().string();
        return JSON_DESERIALIZER.readValue(strResponse, responseFormat);
    }

}
