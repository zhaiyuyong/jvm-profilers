#!/bin/sh
set -e

PID=$1

if [ -z "$PERF_JAVA_TMP" ]; then
  PERF_JAVA_TMP=/tmp
fi

STACKS=$PERF_JAVA_TMP/out-$PID.stacks
COLLAPSED=$PERF_JAVA_TMP/out-$PID.collapsed
PERF_MAP_DIR=$(dirname $(readlink -f $0))/..

if [ -z "$FLAMEGRAPH_DIR" ]; then
  FLAMEGRAPH_DIR="$PERF_MAP_DIR/../flame-graph"
fi

if [ ! -x "$FLAMEGRAPH_DIR/stackcollapse-perf.pl" ]; then
  echo "FlameGraph executable not found at '$FLAMEGRAPH_DIR/stackcollapse-perf.pl'. Please set FLAMEGRAPH_DIR to the root of the clone of https://github.com/brendangregg/FlameGraph."
  exit
fi

if [ -z "$PERF_DATA_FILE" ]; then
  PERF_DATA_FILE=$PERF_JAVA_TMP/perf-$PID.data
fi

if [ -z "$PERF_FLAME_OUTPUT" ]; then
  PERF_FLAME_OUTPUT=flamegraph-$PID.svg
fi

if [ -z "$PERF_FLAME_OPTS" ]; then
    PERF_FLAME_OPTS="--color=java --hash --fontsize=10 --title=java(green)_c++(yellow)_system(red)"
fi

$PERF_MAP_DIR/bin/perf-java-record-stack.sh $*
sudo perf script -i $PERF_DATA_FILE > $STACKS
$FLAMEGRAPH_DIR/stackcollapse-perf.pl $STACKS | tee $COLLAPSED | $FLAMEGRAPH_DIR/flamegraph.pl $PERF_FLAME_OPTS > $PERF_FLAME_OUTPUT
echo "PERF_FLAME_OUTPUT=`readlink -f $PERF_FLAME_OUTPUT`"
