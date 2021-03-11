#!/usr/bin/env bats

# Load lib
load "../lib"

export DOCKER_ARGS="-e IGNITY_KILL_GRACETIME=0 -e IGNITY_KILL_FINALIZE_MAXTIME=0 -e IGNITY_SERVICES_GRACETIME=0 -e IGNITY_CMD_WAIT_FOR_SERVICES_MAXTIME=0"

@test "check permissions with default static mapping" {
  echo 'ls -alh /var/www/static-uid-gid | grep "root root"' | docker::run
  [ "$?" -eq 0 ]
}

@test "check permissions with default dynamic mapping" {
  echo 'ls -alh /var/www/dynamic-uid-gid | grep "root root"' | docker::run
  [ "$?" -eq 0 ]
}

@test "check permissions with non default mapping" {
  echo 'ls -alh /var/www/dynamic-uid-gid | grep "exploit exploit"' | DOCKER_ARGS="${DOCKER_ARGS} -e USERMAP_UID=1000 -e USERMAP_GID=1000 -e USER=exploit" docker::run
  [ "$?" -eq 0 ]
}
