#!/bin/sh

CLASSPATH=""

for f in `ls build/libs/*.jar build/libs/dependencies/*.jar`;do
    CLASSPATH="${CLASSPATH}:$f"
done

echo ${CLASSPATH}

echo "Starting the consumer to consume AVRO messages from the AMQP broker ..."
java -cp $CLASSPATH com.utopian.analytics.amqp.Consumer
