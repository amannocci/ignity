#!/usr/bin/env bats

function docker::run() {
  local docker_container_name=$(tr -dc a-z </dev/urandom | head -c 16 ; echo '')

  docker run \
    --name "ignity-${docker_container_name}" \
    --entrypoint '/init' \
    --rm -i \
    ${DOCKER_ARGS} \
    "${DOCKER_IMAGE}" \
    bash
}
