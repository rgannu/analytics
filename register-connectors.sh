#!/bin/bash

# set an initial value for the flag
SOURCE=0
SINK=0

# read the options
OPTS=$(getopt --option io --long source,sink -n `basename "$0"` -- "$@")
eval set -- "$OPTS"

# extract options and their arguments into variables.
while true ; do
  case "$1" in
    -i|--source) SOURCE=1 ; shift ;;
    -o|--sink) SINK=1 ; shift ;;
    --) shift ; break ;;
    *) echo "Internal error!" ; exit 1 ;;
  esac
done

if [ ${SOURCE} -eq 1 ] || ([ ${SOURCE} -eq 0 ] && [ ${SINK} -eq 0 ])
then
  echo "Registering SOURCE connectors..."
  curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @register-source-postgres.json
fi

if [ ${SINK} -eq 1 ] || ([ ${SOURCE} -eq 0 ] && [ ${SINK} -eq 0 ])
then
  echo "Registering SINK connectors..."
  curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @register-file-sink-postgres.json
  curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @register-jdbc-sink-postgres.json
fi
