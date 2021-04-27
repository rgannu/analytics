#!/bin/bash

# cross-platform version of gnu 'readlink -f'
realpath=$(python -c 'import os; import sys; print (os.path.realpath(sys.argv[1]))' "$0")
scripts=`dirname "$realpath"`
bin=`cd "$scripts/../bin">/dev/null; pwd`

source ${scripts}/functions.sh

TOPIC_PREFIX="dbanalytics.skybridge"
BOOTSTRAP_URL='kafka:9092'

# read the options
OPTS=$(getopt -s bash --option a: --longoptions application-id: -n `basename "$0"` -- "$@")
eval set -- "$OPTS"

# extract options and their arguments into variables.
while true ; do
  case "$1" in
    -a|--application-id) APPLICATION_ID=$2 ; shift 2 ;;
    --) shift ; break ;;
    *) echo "Internal error!" ; exit 1 ;;
  esac
done

TOPICS=`${bin}/kafka-topics.sh --bootstrap-server ${BOOTSTRAP_URL}  --list | grep -E "^${TOPIC_PREFIX}"`
TOPICS=`echo ${TOPICS} | sed -e 's/ /,/g' -e 's/\n//g'`

echo "Reset kafka streams application for the application \"${APPLICATION_ID}\" on the topics: ${TOPICS}"
${bin}/kafka-streams-application-reset.sh --application-id ${APPLICATION_ID} \
    --bootstrap-servers ${BOOTSTRAP_URL} \
    --input-topics "${TOPICS}" --force --execute --to-earliest

echo "Sleep for 10 secs"
sleep_process 10

echo "Kafka topics"
${bin}/kafka-topics.sh --bootstrap-server kafka:9092 --list

exit $?
