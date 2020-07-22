#!/bin/bash

echo ""
echo "****************************************************************"
echo "** Building  rgannu/postgres:9.6"
echo "****************************************************************"
docker build -t "rgannu/postgres:9.6" "postgres"