#!/usr/bin/env bash

# Found current script directory
export RELATIVE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Load common
# shellcheck disable=SC1090
source "${RELATIVE_DIR}/lib.sh"

function test::all {
  declare -a kinds
  kinds=( "preboot" "boot" "envs" "perms" "init" "finalize" "services" )

  local status=0
  for kind in "${kinds[@]}"; do
    local docker_image_tag; docker_image_tag=$(str::random)
    echo "Building docker image with tag: ignity-${docker_image_tag}"
    DOCKER_IMAGE_TAG=${docker_image_tag} DOCKERFILE_PATH="tests/${kind}/Dockerfile.tpl" podman::build
    export DOCKER_IMAGE="ignity-${docker_image_tag}"
    bats -t "${BASE_PROJECT}/tests/${kind}"
    status=$?
    if [ "$status" -ne 0 ]; then
      break
    fi
  done
  return $status
}

test::all
