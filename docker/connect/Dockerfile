FROM debezium/connect:1.2 AS build

ARG customerEnv

LABEL maintainer="rgannu"
ENV CONFLUENT_CONNECT_JDBC_VERSION=5.4.1

USER root
RUN yum install -y epel-release \
    && yum install -y python-setuptools \
    && easy_install supervisor \
    && yum install -y supervisor unzip jq

RUN mkdir -p /kafka/connect/kafka-connect-jdbc

# Download and extract the confluent connect JDBC jar in the /kafka/connect directory (plugin.path)
# RUN curl -sfSL https://packages.confluent.io/maven/io/confluent/kafka-connect-jdbc/${CONFLUENT_CONNECT_JDBC_VERSION}/kafka-connect-jdbc-${CONFLUENT_CONNECT_JDBC_VERSION}.jar -o /kafka/connect/kafka-connect-jdbc/kafka-connect-jdbc-${CONFLUENT_CONNECT_JDBC_VERSION}.jar
# ToDo: Place this in the azure repository (contains fixes to handle arrays and postgis datatypes)
COPY ./kafka-connect-jdbc-${CONFLUENT_CONNECT_JDBC_VERSION}.jar /kafka/connect/kafka-connect-jdbc/kafka-connect-jdbc-${CONFLUENT_CONNECT_JDBC_VERSION}.jar

RUN cp /kafka/connect/debezium-connector-postgres/debezium-core-*.jar /kafka/connect/kafka-connect-jdbc/.
RUN cp /kafka/connect/debezium-connector-postgres/postgresql-*.jar /kafka/connect/kafka-connect-jdbc/.

RUN curl -sfSL https://repo.maven.apache.org/maven2/org/apache/camel/kafkaconnector/camel-file-kafka-connector/0.2.0/camel-file-kafka-connector-0.2.0-package.zip -o /kafka/connect/camel-file-kafka-connector.zip
RUN unzip /kafka/connect/camel-file-kafka-connector*.zip -d /kafka/connect/

RUN curl -sfSL https://repo.maven.apache.org/maven2/org/apache/camel/kafkaconnector/camel-amqp-kafka-connector/0.2.0/camel-amqp-kafka-connector-0.2.0-package.zip -o /kafka/connect/camel-amqp-kafka-connector.zip
RUN unzip /kafka/connect/camel-amqp-kafka-connector*.zip -d /kafka/connect/

RUN curl -sfSL https://repo.maven.apache.org/maven2/org/apache/camel/kafkaconnector/camel-rabbitmq-kafka-connector/0.2.0/camel-rabbitmq-kafka-connector-0.2.0-package.zip -o /kafka/connect/camel-rabbitmq-kafka-connector.zip
RUN unzip /kafka/connect/camel-rabbitmq-kafka-connector*.zip -d /kafka/connect/

# For debugging purposes
# COPY ./log4j.properties /kafka/config/log4j.properties
# COPY ./debezium-core-*.jar /kafka/connect/debezium-connector-postgres/.
# COPY ./debezium-core-*.jar /kafka/connect/kafka-connect-jdbc/.

ADD ./supervisor.sh /supervisor.sh
ADD ./config/supervisor/supervisord.conf /etc/supervisord.conf
ADD ./config/init-env.sh /init-env.sh
RUN chmod 755 /supervisor.sh /init-env.sh

ENTRYPOINT ["/bin/bash", "/supervisor.sh"]
