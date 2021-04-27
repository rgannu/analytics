FROM debezium/connect:1.4 AS build

LABEL maintainer="rgannu"
ENV CONFLUENT_CONNECT_JDBC_VERSION=5.4.1
ENV CAMEL_CONNECT_VERSION=0.6.0
ENV KAFKA_SCHEMA_METADATA_VERSION=1.0.0

USER root
RUN yum install -y epel-release \
    && yum install -y python-setuptools \
    && yum install -y supervisor unzip jq \
    && yum clean all

RUN mkdir -p /kafka/connect/kafka-connect-jdbc

# Download and extract the confluent connect JDBC jar in the /kafka/connect directory (plugin.path)
# RUN curl -sfSL https://packages.confluent.io/maven/io/confluent/kafka-connect-jdbc/${CONFLUENT_CONNECT_JDBC_VERSION}/kafka-connect-jdbc-${CONFLUENT_CONNECT_JDBC_VERSION}.jar -o /kafka/connect/kafka-connect-jdbc/kafka-connect-jdbc-${CONFLUENT_CONNECT_JDBC_VERSION}.jar
# ToDo: Place this in the azure repository (contains fixes to handle arrays and postgis datatypes)
COPY ./kafka-connect-jdbc-${CONFLUENT_CONNECT_JDBC_VERSION}.jar /kafka/connect/kafka-connect-jdbc/kafka-connect-jdbc-${CONFLUENT_CONNECT_JDBC_VERSION}.jar
RUN cp /kafka/connect/debezium-connector-postgres/debezium-core-*.jar /kafka/connect/kafka-connect-jdbc/.
RUN cp /kafka/connect/debezium-connector-postgres/postgresql-*.jar /kafka/connect/kafka-connect-jdbc/.

RUN curl -sfSL https://repo.maven.apache.org/maven2/org/apache/camel/kafkaconnector/camel-file-kafka-connector/${CAMEL_CONNECT_VERSION}/camel-file-kafka-connector-${CAMEL_CONNECT_VERSION}-package.zip -o /tmp/camel-file-kafka-connector.zip
RUN unzip /tmp/camel-file-kafka-connector.zip -d /kafka/connect/
RUN rm -rf /tmp/camel-file-kafka-connector.zip

RUN curl -sfSL https://repo.maven.apache.org/maven2/org/apache/camel/kafkaconnector/camel-rabbitmq-kafka-connector/${CAMEL_CONNECT_VERSION}/camel-rabbitmq-kafka-connector-${CAMEL_CONNECT_VERSION}-package.zip -o /tmp/camel-rabbitmq-kafka-connector.zip
RUN unzip /tmp/camel-rabbitmq-kafka-connector.zip -d /kafka/connect/
RUN rm -rf /tmp/camel-rabbitmq-kafka-connector.zip

COPY ./kafka-schema-metadata-smt-${KAFKA_SCHEMA_METADATA_VERSION}.jar /kafka/connect/camel-rabbitmq-kafka-connector/.
RUN cp /kafka/connect/debezium-connector-postgres/debezium-core-*.jar /kafka/connect/camel-rabbitmq-kafka-connector/.

COPY ./camel-rabbitmq-3.6.0.jar /kafka/connect/camel-rabbitmq-kafka-connector/camel-rabbitmq-3.6.0.jar

COPY ./log4j.properties /kafka/config/log4j.properties

COPY ./supervisor.sh /supervisor.sh
COPY ./config/supervisor/supervisord.conf /etc/supervisord.conf
COPY ./config/init-env.sh /init-env.sh
RUN chmod 755 /supervisor.sh /init-env.sh

ENTRYPOINT ["/bin/bash", "/supervisor.sh"]
