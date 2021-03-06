#!/bin/bash
set -e

PERF_MAP_DIR=$(dirname $(readlink -f $0))/..
PID=$1

if [ -z "$PERF_JAVA_TMP" ]; then
  PERF_JAVA_TMP=/tmp
fi

if [ -z "$PERF_RECORD_SECONDS" ]; then
  PERF_RECORD_SECONDS=30
fi

if [ -z "$PERF_RECORD_FREQ" ]; then
  PERF_RECORD_FREQ=99
fi

if [ -z "$PERF_DATA_FILE" ]; then
  PERF_DATA_FILE=$PERF_JAVA_TMP/perf-$PID.data
fi

sudo perf record -F $PERF_RECORD_FREQ -o $PERF_DATA_FILE -g -p $* -- sleep $PERF_RECORD_SECONDS
$PERF_MAP_DIR/bin/create-java-perf-map.sh $PID "$PERF_MAP_OPTIONS"
