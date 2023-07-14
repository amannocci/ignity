#!/usr/bin/env bats

# Load lib
load "../lib"

export DOCKER_ARGS="-e IGNITY_KILL_GRACETIME=0 -e IGNITY_KILL_FINALIZE_MAXTIME=0 -e IGNITY_SERVICES_GRACETIME=0 -e IGNITY_CMD_WAIT_FOR_SERVICES_MAXTIME=0"

@test "check environment variable from envfile is present" {
  echo 'with-env env | grep "FOOBAR=test"' | podman::run
  [ "$?" -eq 0 ]
}

@test "check environment variable from envfile is overridable" {
  echo 'with-env env | grep "FOOBAR=override"' | DOCKER_ARGS="${DOCKER_ARGS} -e FOOBAR=override" podman::run
  [ "$?" -eq 0 ]
}

@test "check environment variable from envfile are overridable in order" {
  echo 'with-env env | grep "INHERIT=foobar"' | podman::run
  [ "$?" -eq 0 ]
}
