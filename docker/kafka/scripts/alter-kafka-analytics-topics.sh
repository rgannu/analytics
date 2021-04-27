#!/bin/sh

# cross-platform version of gnu 'readlink -f'
realpath=$(python -c 'import os; import sys; print (os.path.realpath(sys.argv[1]))' "$0")
scripts=`dirname "$realpath"`
bin=`cd "$scripts/../bin">/dev/null; pwd`

source ${scripts}/functions.sh

TOPIC_PREFIX="dbanalytics.skybridge"
BOOTSTRAP_URL='kafka:9092'
REPLICATION_FACTOR=1
PARTITIONS=4
# 7 days
RETENTION_MS=$(( 7*24*60*60*1000 ))

TOPICS=`${bin}/kafka-topics.sh --bootstrap-server ${BOOTSTRAP_URL}  --list | grep "^${TOPIC_PREFIX}"`

for topic in `echo ${TOPICS} kafka-schema-registry analytics-statistics analytics-replay`; do
  DESC_TOPIC=`describe_topic ${BOOTSTRAP_URL} ${topic} | grep "PartitionCount" | awk -F' ' '{print $4 "::" $6}'`
  partition_count=`echo ${DESC_TOPIC} | awk -F'::' '{print $1}'`
  replication_factor=`echo ${DESC_TOPIC} | awk -F'::' '{print $2}'`

  if [[ ${partition_count} -ne ${PARTITIONS} ]]; then
    alter_topic ${BOOTSTRAP_URL} ${topic} ${PARTITIONS}
  fi
  alter_topic_config ${BOOTSTRAP_URL} ${topic} "retention.ms" "${RETENTION_MS}"
  describe_topic ${BOOTSTRAP_URL} ${topic}
done

exit 0
