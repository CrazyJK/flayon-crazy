#!/bin/sh

JAVA_OPTS="-Dspring.profiles.active=crazy-linux"
# for JMX monitoring
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote=true"
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.port=58869"
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.ssl=false"
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.authenticate=true"
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.access.file=jmxremote.access"
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.password.file=jmxremote.password"

CURRENT_DIR=`cd . >/dev/null; pwd`
FLAYON_HOME=$CURRENT_DIR
JAVA_HOME=`which java`

echo "Using FLAYON_HOME:  $FLAYON_HOME"
echo "Using JAVA_HOME:    $JAVA_HOME"
echo "Using JAVA_OPTS:    $JAVA_OPTS"

java $JAVA_OPTS -jar "$FLAYON_HOME/target/crazy.war"

