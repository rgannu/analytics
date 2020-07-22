#!/bin/bash
/connect-volume/bin/schema.sh \
  --url "http://schema-registry:18081" \
  --broker-list "kafka:9092" \
  --topic "kafka-schema-registry"
