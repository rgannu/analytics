#!/bin/bash

# cross-platform version of gnu 'readlink -f'
realpath=$(python -c 'import os; import sys; print (os.path.realpath(sys.argv[1]))' "$0")
bin=`dirname "$realpath"`
bin=`cd "$bin">/dev/null; pwd`

${bin}/schema.sh \
  --url "http://schema-registry:18081" \
  --broker-list "kafka:9092" \
  --topic "kafka-schema-registry"
