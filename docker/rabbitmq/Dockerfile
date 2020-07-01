FROM rabbitmq:3.7-management-alpine

RUN apk update \
        && apk add --update supervisor

ADD ./supervisor.sh /supervisor.sh
ADD ./config/supervisor/supervisord.conf /etc/supervisord.conf
ADD ./config/init.sh /usr/local/bin/init.sh
ADD ./config/wait-for-rabbitmq /usr/local/bin/wait-for-rabbitmq

RUN chmod 755 /supervisor.sh /usr/local/bin/init.sh /usr/local/bin/wait-for-rabbitmq

ENTRYPOINT ["/bin/bash", "/supervisor.sh"]
