#!/bin/sh
#
# Copyright (c) 1999-2010 Luca Garulli, Parasoft
#
# 2012-07-31 - Added -w option 
#
# resolve links - $0 may be a softlink
if [ ! -f "running.lock" ]
then
  exit
fi
PRG="$0"

while [ $# -gt 0 ]; do
  case "$1" in
    -w|--wait)
      wait="yes"
      shift 1 ;;
  esac
done

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

if [ "x$JAVA_HOME" = "x" ]
then
   JAVA=java
else
   JAVA=$JAVA_HOME/bin/java
fi

LOG_FILE=$ORIENTDB_HOME/config/server-log.properties
LOG_LEVEL=warning
WWW_PATH=$ORIENTDB_HOME/www
#JAVA_OPTS=-Xms1024m -Xmx1024m

$JAVA -client $JAVA_OPTS -Dorientdb.config.file="$CONFIG_FILE" -Djava.util.logging.config.file="$LOG_FILE" -cp "$ORIENTDB_HOME/lib/orientdb-tools-1.3.0.jar:$ORIENTDB_HOME/lib/*" com.orientechnologies.orient.server.OServerShutdownMain $*

if [ "x$wait" = "xyes" ]
then
  while true ; do
    ps -ef | grep java | grep $ORIENTDB_HOME/lib/orientdb-server > /dev/null || break
    sleep 1;
  done
fi

rm -f running.lock
