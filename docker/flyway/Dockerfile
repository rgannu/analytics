FROM flyway/flyway

ARG name
ARG artifactoryUser
ARG artifactoryPassword

ENV SOURCE_DB_NAME $name

USER root
# Install unzip
RUN apt-get update && apt-get install -y unzip

RUN mkdir -p /flyway/conf
RUN mkdir -p /flyway/sql

COPY ./conf/flyway.conf /flyway/conf
COPY ./download-latest-artifactory.sh /tmp

RUN chmod +x /tmp/download-latest-artifactory.sh
RUN /tmp/download-latest-artifactory.sh $artifactoryUser $artifactoryPassword "unifly-persistence" $UNIFLY_VERSION

RUN unzip /tmp/unifly-persistence.jar "db/migration/*" -d /flyway/sql
RUN unzip /tmp/unifly-persistence.jar "db/migration-navcan/*" -d /flyway/sql
