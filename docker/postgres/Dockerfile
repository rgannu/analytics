FROM postgres:9.6.17 AS build

ARG USE_POSTGIS=true

RUN apt-get update && apt-get install -y wget
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add -
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" >> /etc/apt/sources.list.d/postgresql.list'

# Install wal2json
RUN apt-get install postgresql-$PG_MAJOR-wal2json

FROM postgres:9.6.17
ARG name
LABEL maintainer="Utopian"

ENV DB_NAME=$name
ENV POSTGIS_MAJOR=2.5

RUN apt-get update \
    && apt-get install -f -y --no-install-recommends \
        software-properties-common \
    && if [ "$USE_POSTGIS" != "false" ]; then apt-get install -f -y --no-install-recommends \
        postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
        postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts \
        postgresql-plpython3-$PG_MAJOR python3-dateutil \
        postgis; \
       fi \
    && add-apt-repository "deb http://ftp.debian.org/debian testing main contrib" \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/lib/postgresql/$PG_MAJOR/lib/wal2json.so /usr/lib/postgresql/$PG_MAJOR/lib/
# Copy the custom configuration which will be passed down to the server (using a .sample file is the preferred way of doing it by
# the base Docker image)
COPY postgresql.conf.sample /usr/share/postgresql/postgresql.conf.sample

# Copy the script which will initialize the replication permissions
COPY /docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
