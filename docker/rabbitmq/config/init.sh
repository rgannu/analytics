#!/usr/bin/env bash

echo '[rabbitmq_management,rabbitmq_management_visualiser, rabbitmq_amqp1_0].' > enabled_plugins

rabbitmq-plugins enable rabbitmq_amqp1_0
rabbitmq-plugins enable rabbitmq_shovel
rabbitmq-plugins enable rabbitmq_shovel_management

rabbitmqadmin declare exchange name=analytics-exchange type=topic

rabbitmqadmin declare queue name=analytics durable=false
rabbitmqadmin declare queue name=schema-registry durable=false

rabbitmqadmin declare binding source="analytics-exchange" destination_type="queue" destination="analytics" routing_key="analytics"
rabbitmqadmin declare binding source="analytics-exchange" destination_type="queue" destination="schema-registry" routing_key="analytics-schema-registry"

