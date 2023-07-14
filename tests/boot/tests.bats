#!/usr/bin/env bats

# Load lib
load "../lib"

export DOCKER_ARGS="-e IGNITY_KILL_GRACETIME=0 -e IGNITY_KILL_FINALIZE_MAXTIME=0 -e IGNITY_SERVICES_GRACETIME=0 -e IGNITY_CMD_WAIT_FOR_SERVICES_MAXTIME=0"

@test "check execlined is installed" {
  echo 'command -v execlineb' | podman::run
  [ "$?" -eq 0 ]
}

@test "check container-discover is installed" {
  echo 'command -v container-discover' | podman::run
  [ "$?" -eq 0 ]
}

@test "check fix-perms is installed" {
  echo 'command -v fix-perms' | podman::run
  [ "$?" -eq 0 ]
}

@test "check load-envfile is installed" {
  echo 'command -v load-envfile' | podman::run
  [ "$?" -eq 0 ]
}

@test "check with-env is installed" {
  echo 'command -v with-env' | podman::run
  [ "$?" -eq 0 ]
}

@test "check with-retries is installed" {
  echo 'command -v with-retries' | podman::run
  [ "$?" -eq 0 ]
}
