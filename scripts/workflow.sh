#!/usr/bin/env bash

# Found current script directory
export RELATIVE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Load common
# shellcheck disable=SC1090
source "${RELATIVE_DIR}/lib.sh"

########################################
# Commands implementations.
########################################
function command::help() {
  echo "-- Help Menu"
  echo "> ./scripts/workflow.sh setup    | Setup the project"
  echo "> ./scripts/workflow.sh test     | Test the project"
  echo "> ./scripts/workflow.sh package  | Package the project"
  echo "> ./scripts/workflow.sh help     | Display this help menu"
}

function command::check() {
  log::action "Checking if needed commands are installs"
  case "${1}" in
    test)
      helper::commands_are_present "podman"
      ;;
    package)
      helper::commands_are_present "tar"
      ;;
    *)
      log::failure "interpret argument '${arg}'"
      ;;
  esac
}

function command::setup() {
  # Constants
  local hook_dir="${BASE_PROJECT}/.git/hooks"

  # Create directory
  mkdir -p "${hook_dir}"

  # Remove all old hooks before anything
  log::success "remove old hooks"
  rm -f "${hook_dir}/commit-msg"
  rm -f "${hook_dir}/pre-commit"

  # Copy new ones
  log::success "copy new hooks"
  cp "${RELATIVE_DIR}/hook-commit-msg.sh" "${hook_dir}/commit-msg"
  cp "${RELATIVE_DIR}/hook-pre-commit.sh" "${hook_dir}/pre-commit"
}

function command::test() {
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

function command::package() {
  log::action "Creating dist directory"
  rm -rf dist && mkdir -p dist
  SILENT_STDOUT="true" helper::try "Creating tar archive" tar zcvf dist/ignity.tar.gz -C src/ .
}

# Parse argument
arg="${1}"
shift

case "${arg}" in
  help)
    command::help
    ;;
  setup)
    command::setup
    ;;
  test)
    command::check "test"
    command::test
    ;;
  package)
    command::check "package"
    command::package
    ;;
  *)
    log::failure "interpret argument '${arg}'"
    command::help
    ;;
esac
