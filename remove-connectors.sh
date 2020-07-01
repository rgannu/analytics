#!/bin/sh

# Remove all connectors
for connector in `curl -s http://localhost:8083/connectors | jq -r .[]`; do
  echo "Removing connector: ${connector}"
  curl -X DELETE http://localhost:8083/connectors/${connector}
done