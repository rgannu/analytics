FROM rgannu/postgres:9.6

LABEL maintainer="rgannu"

COPY ./docker-entrypoint-initdb.d/create-db.sql /docker-entrypoint-initdb.d/
COPY ./docker-entrypoint-initdb.d/add-permissions.sh /docker-entrypoint-initdb.d/