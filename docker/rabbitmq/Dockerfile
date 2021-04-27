FROM rabbitmq:3.8.9-management-alpine

RUN apk update \
        && apk add --update supervisor

COPY ./supervisor.sh /supervisor.sh
COPY ./config/supervisor/supervisord.conf /etc/supervisord.conf
COPY ./config/init.sh /usr/local/bin/init.sh
COPY ./config/wait-for-rabbitmq /usr/local/bin/wait-for-rabbitmq

RUN chmod 755 /supervisor.sh /usr/local/bin/init.sh /usr/local/bin/wait-for-rabbitmq

ENTRYPOINT ["/bin/bash", "/supervisor.sh"]
