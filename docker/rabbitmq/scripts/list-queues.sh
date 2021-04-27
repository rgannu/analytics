#!/bin/bash

# set an initial value for the flag
PREFIX_QUEUE=""
DEFAULT_PREFIX='analytics|(-)*[0-9]'

# read the options
OPTS=$(getopt -s bash --option p: --longoptions prefix -n `basename "$0"` -- "$@")
eval set -- "$OPTS"

# extract options and their arguments into variables.
while true ; do
  case "$1" in
    -p|--prefix) PREFIX_QUEUE=$2 ; shift 2 ;;
    --) shift ; break ;;
    *) echo "Internal error!" ; exit 1 ;;
  esac
done

if [[ "${PREFIX_QUEUE}" == "" ]]; then
  PREFIX_QUEUE=${DEFAULT_PREFIX}
fi

for queue_msg in `rabbitmqctl list_queues -s  name messages --online | egrep -i "^(${PREFIX_QUEUE})" | awk -F'\t' '{print $1 "::" $2}'`; do
  queue=`echo ${queue_msg} | awk -F'::' '{print $1}'`
  msg_count=`echo ${queue_msg} | awk -F'::' '{print $2}'`

  echo "Queue \"${queue}\" has ${msg_count} messages."
done

exit 0

