#!/bin/bash

echo ""
echo "****************************************************************"
echo "** Building  unifly/rgannu:9.6"
echo "****************************************************************"
docker build -t "rgannu/postgres:9.6" "postgres"