#!/bin/sh
#
# Copyright (c) 1999-2012 Luca Garulli, Parasoft
#

# resolve links - $0 may be a softlink
PRG="$0"

while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

# Get standard environment variables
PRGDIR=`dirname "$PRG"`

# Only set ORIENTDB_HOME if not already set
[ -f "$ORIENTDB_HOME"/bin/orient.sh ] || ORIENTDB_HOME=`cd "$PRGDIR/.." ; pwd`
export ORIENTDB_HOME

if [ ! -f "${CONFIG_FILE}" ]
then
  CONFIG_FILE=$ORIENTDB_HOME/config/server-config.xml
fi

if [ ! -f "${LOG_FILE}" ]
then
  LOG_FILE=$ORIENTDB_HOME/config/server-log.properties
fi

if [ "x$JAVA_HOME" = "x" ]
then
   JAVA=java
else
   JAVA=$JAVA_HOME/bin/java
fi

LOG_CONSOLE_LEVEL=info
LOG_FILE_LEVEL=fine
WWW_PATH=$ORIENTDB_HOME/www
ORIENTDB_SETTINGS="-Dprofiler.enabled=true -Dcache.level1.enabled=false -Dcache.level2.strategy=1"
JAVA_OPTS_SCRIPT=-XX:+HeapDumpOnOutOfMemoryError
JAVA_OPTS="-Xms200m -Xmx1g -Djava.awt.headless=true"
touch running.lock
echo Parasoft data repository server started...

$JAVA -server $JAVA_OPTS $JAVA_OPTS_SCRIPT $ORIENTDB_SETTINGS -Djava.util.logging.config.file="$LOG_FILE" -Dorientdb.config.file="$CONFIG_FILE" -Dorientdb.www.path="$WWW_PATH" -Dorientdb.build.number="16" -cp "$ORIENTDB_HOME/lib/orientdb-server-1.3.0.jar:$ORIENTDB_HOME/lib/*" com.orientechnologies.orient.server.OServerMain

echo Parasoft data repository server has been shutdown.
