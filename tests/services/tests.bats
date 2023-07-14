#!/usr/bin/env bats

# Load lib
load "../lib"

export DOCKER_ARGS="-e IGNITY_KILL_GRACETIME=0 -e IGNITY_KILL_FINALIZE_MAXTIME=0 -e IGNITY_SERVICES_GRACETIME=0 -e IGNITY_CMD_WAIT_FOR_SERVICES_MAXTIME=0"

@test "check default service had run" {
  result=$(echo 'test -d /etc/ignity' | podman::run)
  echo "${result}" | grep "default service"
  [ "$?" -eq 0 ]
}

@test "check no-start service hadn't run" {
  result=$(echo 'test -d /etc/ignity' | podman::run)
  echo "${result}" | grep -v "no-start service"
  [ "$?" -eq 0 ]
}

@test "check no-start service at build time can be started" {
  result=$(echo 'rm -f /run/ignity/services-state/no-start-at-build-time/down && s6-svc -u /run/ignity/services-state/no-start-at-build-time' | podman::run)
  echo "${result}" | grep "no-start service at build time"
  [ "$?" -eq 0 ]
}

@test "check no-start service at runtime can be started" {
  result=$(echo 'rm -f /run/ignity/services-state/no-start-at-runtime/down && s6-svc -u /run/ignity/services-state/no-start-at-runtime' | podman::run)
  echo "${result}" | grep "no-start service at runtime"
  [ "$?" -eq 0 ]
}
