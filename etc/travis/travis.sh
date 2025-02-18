#!/bin/bash
# Abort on Error
set -e

export PING_SLEEP=30s
export WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export BUILD_OUTPUT=$WORKDIR/build.out

touch $BUILD_OUTPUT

dump_output() {
   echo Tailing the last 500 lines of output:
   tail -500 $BUILD_OUTPUT
}
error_handler() {
  echo ERROR: An error was encountered with the build.
  dump_output
  exit 1
}
# If an error occurs, run our error handler to output a tail of the build
trap 'error_handler' ERR

# Set up a repeating loop to send some output to Travis.

bash -c "while true; do tail -5 $BUILD_OUTPUT; sleep $PING_SLEEP; done" &
PING_LOOP_PID=$!

if [ "$1" = "glassfish-copyright:copyright" ]; then
    mvn glassfish-copyright:copyright
else
    mvn -e -U -B clean install -Pstaging $1 >> $BUILD_OUTPUT 2>&1
fi

# The build finished without returning an error so dump a tail of the output
dump_output

# nicely terminate the ping output loop
kill $PING_LOOP_PID