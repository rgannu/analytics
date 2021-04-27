#!/usr/bin/env bash

echo '[rabbitmq_management,rabbitmq_management_visualiser, rabbitmq_amqp1_0].' > enabled_plugins

rabbitmq-plugins enable rabbitmq_amqp1_0
rabbitmq-plugins enable rabbitmq_shovel
rabbitmq-plugins enable rabbitmq_shovel_management

rabbitmqadmin declare exchange name=analytics-exchange type=fanout
rabbitmqadmin declare exchange name=analytics-schema-exchange type=fanout
rabbitmqadmin declare exchange name=analytics-statistics-exchange type=fanout

rabbitmqadmin declare queue name=analytics durable=false
rabbitmqadmin declare queue name=analytics-statistics durable=false
rabbitmqadmin declare queue name=analytics-schema-registry durable=false

rabbitmqadmin declare queue name=src-queue durable=false
rabbitmqadmin declare queue name=dest-queue durable=false

rabbitmqadmin declare binding source="analytics-exchange" destination_type="queue" destination="analytics" routing_key="analytics"
rabbitmqadmin declare binding source="analytics-schema-exchange" destination_type="queue" destination="analytics-schema-registry" routing_key="analytics-schema-registry"
rabbitmqadmin declare binding source="analytics-statistics-exchange" destination_type="queue" destination="analytics-statistics" routing_key="analytics-statistics"

rabbitmqctl set_parameter shovel my-shovel '{"src-protocol": "amqp091", "src-uri": "amqp://", "src-queue": "src-queue", "dest-protocol": "amqp091", "dest-uri": "amqp://", "dest-queue": "dest-queue"}'
