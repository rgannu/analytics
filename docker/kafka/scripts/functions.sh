#!/bin/bash

PROGRESS_BAR_WIDTH=50  # progress bar length in characters

draw_progress_bar() {
  # Arguments: current value, max value, unit of measurement (optional)
  local __value=$1
  local __max=$2
  local __unit=${3:-""}  # if unit is not supplied, do not display it

  # Calculate percentage
  if (( $__max < 1 )); then __max=1; fi  # anti zero division protection
  local __percentage=$(( 100 - ($__max*100 - $__value*100) / $__max ))

  # Rescale the bar according to the progress bar width
  local __num_bar=$(( $__percentage * $PROGRESS_BAR_WIDTH / 100 ))

  # Draw progress bar
  printf "["
  for b in $(seq 1 $__num_bar); do printf "#"; done
  for s in $(seq 1 $(( $PROGRESS_BAR_WIDTH - $__num_bar ))); do printf " "; done
  printf "] $__percentage%% ($__value / $__max $__unit)\r"
}

sleep_process() {
  local __sleep_time_in_secs=$1
  elapsed=0

  echo "Sleeping for ${__sleep_time_in_secs} secs..."

  while true; do
    # Get current value of uploaded bytes
    elapsed=$(( $elapsed+1 ))

    # Draw a progress bar
    draw_progress_bar $elapsed $__sleep_time_in_secs "secs"

    # Check if we reached 100%
    if [[ $elapsed == $__sleep_time_in_secs ]]; then break; fi
    sleep 1  # Wait before redrawing
  done
  # Go to the newline at the end of upload
  printf "\n"
}

describe_topic() {
  local DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
  local __bootstrap_url=$1
  local __topic=$2

  ${DIR}/../bin/kafka-topics.sh --bootstrap-server ${__bootstrap_url} --topic ${__topic} --describe
}

create_topic() {
  local DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
  local __bootstrap_url=$1
  local __topic=$2
  local __partitions=$3
  local __replication_factor=$4
  local __config=$5

  echo "Creating the kafka topic \"${topic}\" with \"${__partitions}\" partitions, replication factor of \"${__replication_factor}\" and configuration \"${__config}\""
  ${DIR}/../bin/kafka-topics.sh --bootstrap-server ${__bootstrap_url} --create --topic ${__topic} --partitions ${__partitions} --replication-factor ${__replication_factor} --config=${__config}

  if [[ $? -eq 0 ]]; then
    echo "Created topic \"${topic}\" successfully"
  fi
}

alter_topic() {
  local DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
  local __bootstrap_url=$1
  local __topic=$2
  local __partitions=$3
  # https://issues.apache.org/jira/browse/KAFKA-1543
  # replication factor cannot be changed like --replication-factor ${__replication_factor} !
  local __replication_factor=$4

  echo "Altering the kafka topic \"${topic}\" with \"${__partitions}\" partitions"
  ${DIR}/../bin/kafka-topics.sh --bootstrap-server ${__bootstrap_url} --alter --topic ${__topic} --partitions ${__partitions}

  if [[ $? -eq 0 ]]; then
    echo "Altered topic \"${topic}\" successfully"
  fi
}

alter_topic_config() {
  local DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
  local __bootstrap_url=$1
  local __topic=$2
  local __config_key=$3
  local __config_value=$4

  echo "Altering the kafka topic \"${topic}\" configuration \"${__config_key}\" with value \"${__config_value}\""
  ${DIR}/../bin/kafka-configs.sh --alter --bootstrap-server ${__bootstrap_url} --topic ${__topic} --add-config ${__config_key}=${__config_value}

  if [[ $? -eq 0 ]]; then
    echo "Altered topic \"${topic}\" successfully"
  fi
}

topic_message_count() {
  local DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
  local __bootstrap_url=$1
  local __topic=$2

  echo
  echo "  Message count of the topic: ${__topic} "
  echo "    # of messages (approx) = (latest - earliest) per partition "
  ###
  # https://rmoff.net/2020/09/08/counting-the-number-of-messages-in-a-kafka-topic/
  # This is not accurate.
  # Weeco: Also because of gaps in compacted topics this won’t work If you don’t want to consume all messages
  #   to count the number of records I have just one idea how to get a rough estimate.
  #   I described that here: https://github.com/cloudhut/kowl/issues/83
  ###
  # Get Latest Offset
  echo "Get Latest Offset of the topic: ${__topic} per partition"
  ${DIR}/../bin/kafka-run-class.sh kafka.tools.GetOffsetShell \
    --broker-list ${__bootstrap_url} \
    --topic ${__topic} \
    --time -1

  # Get Earliest Offset
  echo "Get Earliest Offset of the topic: ${__topic} per partition"
  ${DIR}/../bin/kafka-run-class.sh kafka.tools.GetOffsetShell \
    --broker-list ${__bootstrap_url} \
    --topic ${__topic} \
    --time -2
}
