#!/usr/bin/env bats

# Load lib
load "../lib"

export DOCKER_ARGS="-e IGNITY_KILL_GRACETIME=0 -e IGNITY_KILL_FINALIZE_MAXTIME=0 -e IGNITY_SERVICES_GRACETIME=0 -e IGNITY_CMD_WAIT_FOR_SERVICES_MAXTIME=0"

@test "check permissions with default static mapping" {
  echo 'ls -alh /var/www/static-uid-gid | grep -- "-rw------"' | podman::run
  [ "$?" -eq 0 ]
}

@test "check permissions with multi mapping" {
  echo 'ls -alh /var/www/multi-uid-gid-01 | grep -- "-rw-r--r--"' | podman::run
  [ "$?" -eq 0 ]
}

@test "check owner with default dynamic mapping" {
  echo 'ls -alh /var/www/dynamic-uid-gid | grep -- "root root"' | podman::run
  [ "$?" -eq 0 ]
}

@test "check owner with non default mapping" {
  echo 'ls -alh /var/www/dynamic-uid-gid | grep -- "exploit exploit"' | DOCKER_ARGS="${DOCKER_ARGS} -e USERMAP_UID=1000 -e USERMAP_GID=1000 -e USER=exploit" podman::run
  [ "$?" -eq 0 ]
}

@test "check permissions with non default mapping" {
  echo 'ls -alh /var/www/dynamic-uid-gid | grep -- "-rw-------"' | DOCKER_ARGS="${DOCKER_ARGS} -e USERMAP_UID=1000 -e USERMAP_GID=1000 -e USER=exploit" podman::run
  [ "$?" -eq 0 ]
}

@test "check skip perms stage" {
  result=$(echo 'test -d /etc/ignity' | DOCKER_ARGS="${DOCKER_ARGS} -e IGNITY_SKIP_PERMS=1" podman::run)
  echo "${result}" | grep -v "Applying ownership & permissions fixes"
  [ "$?" -eq 0 ]
}

@test "check execution perms stage" {
  result=$(echo 'test -d /etc/ignity' | DOCKER_ARGS="${DOCKER_ARGS} -e IGNITY_SKIP_PERMS=0" podman::run)
  echo "${result}" | grep "Applying ownership & permissions fixes"
  [ "$?" -eq 0 ]
}
