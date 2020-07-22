#!/bin/bash

# cross-platform version of gnu 'readlink -f'
realpath=$(python -c 'import os; import sys; print (os.path.realpath(sys.argv[1]))' "$0")
bin=`dirname "$realpath"`
bin=`cd "$bin">/dev/null; pwd`

# set an initial value for the flag
SOURCE=0
SINK=0

# read the options
OPTS=$(getopt -s bash --option io --longoptions source,sink -n `basename "$0"` -- "$@")
eval set -- "${OPTS}"

# extract options and their arguments into variables.
while true ; do
  case "$1" in
    -i|--source) SOURCE=1 ; shift ;;
    -o|--sink) SINK=1 ; shift ;;
    --) shift ; break ;;
    *) echo "Internal error!" ; exit 1 ;;
  esac
done

if [[ ${SOURCE} -eq 1 ]] || ([[ ${SOURCE} -eq 0 ]] && [[ ${SINK} -eq 0 ]])
then
  echo "Registering SOURCE connectors..."
  curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:18083/connectors/ -d @"${bin}/"register-source-postgres.json
fi

if [[ ${SINK} -eq 1 ]] || ([[ ${SOURCE} -eq 0 ]] && [[ ${SINK} -eq 0 ]])
then
  echo "Registering SINK connectors..."
  curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:18083/connectors/ -d @"${bin}/"register-avro-file-sink-postgres.json
  curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:18083/connectors/ -d @"${bin}/"register-json-file-sink-connector.json
  curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:18083/connectors/ -d @"${bin}/"register-amqp-sink-connector.json
  curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:18083/connectors/ -d @"${bin}/"register-amqp-schema-dump-sink-connector.json
  curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:18083/connectors/ -d @"${bin}/"register-jdbc-sink-postgres.json
fi
