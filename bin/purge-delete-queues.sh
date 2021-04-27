#!/bin/bash

sudo rabbitmqctl list_queues -s  name messages --online | egrep -i "^[-]?([0-9])|(analytics.utopian|analytics.navcan|analytics-schema-registry.navcan)" > /tmp/rabbitmq_queues_info

while IFS= read -r line; do
  queue=$(echo $line | cut -f1 --delimiter=' ')
  msg_count=$(echo $line | cut -f2 --delimiter=' ')

  if [[ ${msg_count} -gt 0 ]]; then
    #echo "Queue \"${queue}\" is having ${msg_count} messages"
    #echo "Purging queue: \"$queue\" "
    echo "sudo rabbitmqctl purge_queue ${queue}"
  fi

  if [[ ${queue} =~ [0-9] ]]; then
    #echo "Deleting random queue \"${queue}\""
    echo "sudo rabbitmqctl delete_queue ${queue}"
  fi 
done < /tmp/rabbitmq_queues_info > /tmp/rabbitmq-purge-delete-cmds

chmod +x /tmp/rabbitmq-purge-delete-cmds
/tmp/rabbitmq-purge-delete-cmds

exit 0
