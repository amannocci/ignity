#!/usr/bin/env bats

# Load lib
load "../lib"

export DOCKER_ARGS="-e IGNITY_KILL_GRACETIME=0 -e IGNITY_KILL_FINALIZE_MAXTIME=0 -e IGNITY_SERVICES_GRACETIME=0 -e IGNITY_CMD_WAIT_FOR_SERVICES_MAXTIME=0"

@test "check init scripts had run" {
  echo 'ls -alh /tmp/init-tests' | docker::run
  [ "$?" -eq 0 ]
}

@test "check init scripts had run in order" {
  echo 'cat /tmp/init-tests | grep "foobar"' | docker::run
  [ "$?" -eq 0 ]
}
