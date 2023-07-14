#!/usr/bin/env bats

function podman::run() {
  local docker_container_name=$(tr -dc a-z </dev/urandom | head -c 16 ; echo '')

  podman run \
    --name "ignity-${docker_container_name}" \
    --entrypoint '/init' \
    --rm -i \
    ${DOCKER_ARGS} \
    "${DOCKER_IMAGE}" \
    bash
}
