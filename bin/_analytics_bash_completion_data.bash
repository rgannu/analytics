# Defines functions used by analytics_bash_completion.bash and analytics.
# This file could also be generated during the build so that developers
# do need to remember editing this file.

declare -A commands=( \
  ["version"]="\t\t\t\tPrint the version" \
  ["register|register-connectors"]="\t\tRegister the Kafka connectors" \
  ["remove|remove-connectors"]="\t\tRemove the Kafka connectors" \
  ["validate|validate-connectors"]="\t\tValidate the Kafka connectors" \
  ["purge-prefix|purge-prefix-queues"]="\tPurge RabbitMQ queues for the given prefix (default: analytics queues)" \
  ["purge-delete|purge-delete-queues"]="\tPurge and delete analytics RabbitMQ queues" \
  ["list|list-queues"]="\t\t\tQuery and list analytics RabbitMQ queues" \
  ["help"]="\t\t\t\t\tPrint usage" \
)

# Outputs the space-separated list of analytics commands
analytics_commands() {
  for command in "${!commands[@]}"; do
    echo -e "$command";
  done
}
