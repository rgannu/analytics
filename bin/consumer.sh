#!/bin/bash

# cross-platform version of gnu 'readlink -f'
realpath=$(python -c 'import os; import sys; print (os.path.realpath(sys.argv[1]))' "$0")
bin=`dirname "$realpath"`
bin=`cd "$bin">/dev/null; pwd`

JAR_PATH="${bin}/.."
VERSION=`${bin}/version.sh | grep "Version" | awk -F'Version: ' '{print $2}'`
if [[ "${VERSION}" == "" ]]; then
  # Running local
  ${bin}/../gradlew getVersion > /tmp/version
  VERSION=`grep -e '^Version: ' /tmp/version | awk -F' ' '{print $2}'`
  JAR_PATH="${bin}/../analytics-common/build/libs"
fi

CLASSPATH="${JAR_PATH}/analytics-common-${VERSION}.jar"
echo $CLASSPATH

echo "Starting the consumer to consume AVRO messages from the AMQP broker ..."
java -cp $CLASSPATH com.utopian.analytics.amqp.Consumer $@
