#!/bin/sh

# cross-platform version of gnu 'readlink -f'
realpath=$(python -c 'import os; import sys; print (os.path.realpath(sys.argv[1]))' "$0")
scripts=`dirname "$realpath"`
bin=`cd "$scripts/../bin">/dev/null; pwd`

source ${scripts}/functions.sh

TOPICS=`${bin}/kafka-topics.sh --zookeeper zookeeper:2181 --list`
echo "Existing Kafka Topics: "
echo ${TOPICS}

BOOTSTRAP_URL='kafka:9092'
REPLICATION_FACTOR=1
PARTITIONS=1
CONFIG='cleanup.policy=compact'

if [[ $TOPICS == *"my_connect_configs"* ]]; then
  echo "Topic 'my_connect_configs' already exists"
else
  create_topic ${BOOTSTRAP_URL} 'my_connect_configs' ${PARTITIONS} ${REPLICATION_FACTOR} ${CONFIG}
fi

if [[ $TOPICS == *"my_connect_offsets"* ]]; then
  echo "Topic 'my_connect_offsets' already exists"
else
  create_topic ${BOOTSTRAP_URL} 'my_connect_offsets' ${PARTITIONS} ${REPLICATION_FACTOR} ${CONFIG}
fi

if [[ $TOPICS == *"my_connect_statuses"* ]]; then
  echo "Topic 'my_connect_statuses' already exists"
else
  create_topic ${BOOTSTRAP_URL} 'my_connect_statuses' ${PARTITIONS} ${REPLICATION_FACTOR} ${CONFIG}
fi

exit 0
