FROM debezium/connect:1.2

LABEL maintainer="Unifly"
ENV CONFLUENT_CONNECT_JDBC_VERSION=5.4.1

RUN mkdir -p /kafka/connect/kafka-connect-jdbc

# Download and extract the confluent connect JDBC jar in the /kafka/connect directory (plugin.path)
# RUN curl -sfSL https://packages.confluent.io/maven/io/confluent/kafka-connect-jdbc/${CONFLUENT_CONNECT_JDBC_VERSION}/kafka-connect-jdbc-${CONFLUENT_CONNECT_JDBC_VERSION}.jar -o /kafka/connect/kafka-connect-jdbc/kafka-connect-jdbc-${CONFLUENT_CONNECT_JDBC_VERSION}.jar
# ToDo: Place this in the azure repository (contains fixes to handle arrays and postgis datatypes)
COPY ./kafka-connect-jdbc-${CONFLUENT_CONNECT_JDBC_VERSION}.jar /kafka/connect/kafka-connect-jdbc/kafka-connect-jdbc-${CONFLUENT_CONNECT_JDBC_VERSION}.jar

RUN cp /kafka/connect/debezium-connector-postgres/debezium-core-*.jar /kafka/connect/kafka-connect-jdbc/.
RUN cp /kafka/connect/debezium-connector-postgres/postgresql-*.jar /kafka/connect/kafka-connect-jdbc/.

# For debugging purposes
# COPY ./log4j.properties /kafka/config/log4j.properties
# COPY ./debezium-core-*.jar /kafka/connect/debezium-connector-postgres/.
# COPY ./debezium-core-*.jar /kafka/connect/kafka-connect-jdbc/.
