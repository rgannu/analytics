#!/usr/bin/env bash

rabbitmq-plugins enable rabbitmq_shovel
rabbitmq-plugins enable rabbitmq_shovel_management

rabbitmqadmin declare queue name=src-queue durable=false
rabbitmqadmin declare queue name=dest-queue durable=false

rabbitmqctl set_parameter shovel my-shovel '{"src-protocol": "amqp091", "src-uri": "amqp://", "src-queue": "src-queue", "dest-protocol": "amqp091", "dest-uri": "amqp://", "dest-queue": "dest-queue"}'
