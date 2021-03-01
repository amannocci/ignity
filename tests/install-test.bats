#!/usr/bin/env bats

# Load lib
load "lib"

export DOCKER_ARGS="-e IGNITY_KILL_GRACETIME=0 -e S6_KILL_FINISH_MAXTIME=0 -e IGNITY_SERVICES_GRACETIME=0 -e IGNITY_CMD_WAIT_FOR_SERVICES_MAXTIME=0"

@test "check execlined is installed" {
  echo 'command -v execlineb' | docker::run
  [ "$?" -eq 0 ]
}

@test "check container-discover is installed" {
  echo 'command -v container-discover' | docker::run
  [ "$?" -eq 0 ]
}

@test "check fix-perms is installed" {
  echo 'command -v fix-perms' | docker::run
  [ "$?" -eq 0 ]
}

@test "check load-envfile is installed" {
  echo 'command -v load-envfile' | docker::run
  [ "$?" -eq 0 ]
}

@test "check with-env is installed" {
  echo 'command -v with-env' | docker::run
  [ "$?" -eq 0 ]
}

@test "check with-retries is installed" {
  echo 'command -v with-retries' | docker::run
  [ "$?" -eq 0 ]
}
