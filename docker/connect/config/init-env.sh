#!/bin/bash
set -e

mkdir -p /secrets
PROP_FILE="/secrets/amqp.properties"

# Create the secrets file
echo "# Secrets file (auto-generated)" > ${PROP_FILE}

#
# Process all environment variables that start with 'AMQP_'
#
for VAR in `env`
do
  if [[ ${VAR} =~ ^AMQP ]]; then
    prop_name=`echo "$VAR" | sed -e "s/^AMQP_//g" | awk -F'=' '{print $1}' | tr '[:upper:]' '[:lower:]' | tr _ .`
    prop_val=`echo "$VAR" | awk -F'=' '{$1="";print substr($0,2)}' | sed -e "s/ /=/g"`
    echo "--- Setting property : $prop_name=${prop_val}"
    echo "$prop_name=${prop_val}" >> ${PROP_FILE}
  fi
done
