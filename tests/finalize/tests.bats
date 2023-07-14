#!/usr/bin/env bats

# Load lib
load "../lib"

export DOCKER_ARGS="-e IGNITY_KILL_GRACETIME=0 -e IGNITY_KILL_FINALIZE_MAXTIME=0 -e IGNITY_SERVICES_GRACETIME=0 -e IGNITY_CMD_WAIT_FOR_SERVICES_MAXTIME=0"

@test "check finalize scripts had run" {
  result=$(echo 'test -d /etc/ignity' | podman::run)
  echo "${result}" | grep "We are in finalize stage"
  [ "$?" -eq 0 ]
}
