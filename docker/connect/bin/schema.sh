#!/bin/bash

# cross-platform version of gnu 'readlink -f'
realpath=$(python -c 'import os; import sys; print (os.path.realpath(sys.argv[1]))' "$0")
bin=`dirname "$realpath"`
bin=`cd "$bin">/dev/null; pwd`

OUTPUT_DIR="/tmp/schema"
rm -rf ${OUTPUT_DIR} && mkdir -p ${OUTPUT_DIR}

USAGE_MSG="Usage: $0 -u|--url <Base schema-registry URL> [-b|--broker-list <Broker list>] [-t|--topic <topic>]"

if (($# == 0))
then
  echo "No positional arguments specified. ${USAGE_MSG}"
  exit 1
fi

# read the options
OPTS=$(getopt -s bash --option u:b:t: --longoptions url:,broker-list:,topic: -n `basename "$0"` -- "$@")
[[ $? -eq 0 ]] || {
  echo "Incorrect options provided. ${USAGE_MSG}"
  exit 1
}

eval set -- "${OPTS}"

# extract options and their arguments into variables.
while true ; do
  case "$1" in
    -u|--url) BASE_URL=$2 ; shift 2 ;;
    -b|--broker-list) BROKER_LIST=$2 ; shift 2 ;;
    -t|--topic) TOPIC=$2 ; shift 2 ;;
    --) shift ; break ;;
    *) echo "Internal error!" ; exit 1 ;;
  esac
done

echo "URL:${BASE_URL}"
echo "Broker List:${BROKER_LIST}"
echo "Topic:${TOPIC}"

if [[ "${BASE_URL}" == "" ]]; then
  echo "Incorrect options provided. ${USAGE_MSG}"
  exit 1
fi

if ([[ "${BROKER_LIST}" == "" ]] && [[ "${TOPIC}" != "" ]]) ||
   ([[ "${BROKER_LIST}" != "" ]] && [[ "${TOPIC}" == "" ]]); then
  echo "When given both options --broker-list and --topic MUST be given. ${USAGE_MSG}"
  exit 1
fi

for VAR in `curl "${BASE_URL}/subjects" | jq '.[]' | sed -e 's/"//g'`
do
  SCHEMA_URL="${BASE_URL}/subjects/${VAR}/versions/latest/schema"
  echo "Retrieving Schema of ${VAR} from URL:${SCHEMA_URL}"
  SCHEMA=`curl ${SCHEMA_URL} | jq '.'`
  echo ${SCHEMA} > ${OUTPUT_DIR}/${VAR}-schema.json
done


if [[ ${TOPIC} != "" ]]; then
  for jsonFile in `ls ${OUTPUT_DIR}/*.json`
  do
    KEY=`echo ${jsonFile} | awk -F "/" '{print $5}' | sed -e 's/\.json//g' -e 's/\./_/g'`
    VALUE=`cat ${jsonFile}`
    echo "Producing AVRO message schema to the kafka topic:${TOPIC} with KEY:${KEY} and JSON schema as value"
#    echo "KEY:${KEY}"
#    echo "VALUE:${VALUE}"
    echo "${KEY}:${VALUE}" | /kafka/bin/kafka-console-producer.sh \
      --broker-list ${BROKER_LIST} \
      --topic ${TOPIC} \
      --property "parse.key=true" \
      --property "key.separator=:"
  done
fi
