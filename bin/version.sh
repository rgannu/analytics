#!/bin/bash

# cross-platform version of gnu 'readlink -f'
realpath=$(python -c 'import os; import sys; print (os.path.realpath(sys.argv[1]))' "$0")
bin=`dirname "$realpath"`
bin=`cd "$bin">/dev/null; pwd`

INSTALL_DIR="/opt/utopian/analytics"
ZIP_PATH="${bin}/.."

if [[ "`uname`" == 'Linux' && -d "${INSTALL_DIR}" ]]; then
  ZIP_PATH="${bin}/.."
  JAR_PATH="${ZIP_PATH}"
else
  # Running local
  ${bin}/../gradlew getVersion > /tmp/version
  VERSION=`grep -e '^Version: ' /tmp/version | awk -F' ' '{print $2}'`
  ZIP_PATH="${bin}/../build/distributions"
  JAR_PATH="${ZIP_PATH}/../libs"
fi

if compgen -G "${ZIP_PATH}/analytics-*.zip" > /dev/null; then
  JAR_FILE=`ls -al ${JAR_PATH}/*.jar | head -1 | awk -F' ' '{print $9}'`
  VERSION_INFO=`/usr/bin/unzip -p ${JAR_FILE} META-INF/MANIFEST.MF | grep 'Implementation-Version' | sed -e 's/Implementation-//g'`
  COMMIT_INFO=`/usr/bin/unzip -p ${JAR_FILE} META-INF/MANIFEST.MF | grep 'Commit-Id'`

  echo "${VERSION_INFO}"
  echo "${COMMIT_INFO}"
else
  echo "JAR file: $ZIP_PATH/analytics-*.jar is missing!"
  exit 1
fi

exit 0
