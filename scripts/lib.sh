#!/usr/bin/env bash

# Strict mode
set -e
trap 's=$?; echo >&2 "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

# Found current script directory
RELATIVE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Found project directory
BASE_PROJECT="$(dirname "${RELATIVE_DIR}")"

#######################################
# Log an action.
# Globals:
#   DISABLE_CONSOLE_COLORS
# Arguments:
#   ${@}: Any texts.
# Outputs:
#   Log a message as action.
#######################################
function log::action() {
  local disable_console_colors; disable_console_colors=$(env::get_or_empty "DISABLE_CONSOLE_COLORS")
  if [ -z "${disable_console_colors}" ]; then
    echo -e "\033[33m⇒\033[0m ${@}"
  else
    echo -e "${@}"
  fi
}

#######################################
# Log a failure.
# Globals:
#   DISABLE_CONSOLE_COLORS
# Arguments:
#   ${@}: Any texts.
# Outputs:
#   Log a message as failure.
#######################################
function log::failure() {
  local disable_console_colors; disable_console_colors=$(env::get_or_empty "DISABLE_CONSOLE_COLORS")
  if [ -z "${disable_console_colors}" ]; then
    echo -e "\033[31m✗\033[0m Failed to ${@}" >&2
  else
    echo -e "Failed to ${@}" >&2
  fi
}

#######################################
# Log a success.
# Globals:
#   DISABLE_CONSOLE_COLORS
# Arguments:
#   ${@}: Any texts.
# Outputs:
#   Log a message as success.
#######################################
function log::success() {
  local disable_console_colors; disable_console_colors=$(env::get_or_empty "DISABLE_CONSOLE_COLORS")
  if [ -z "${disable_console_colors}" ]; then
    echo -e "\033[32m✓\033[0m Succeeded to ${@}"
  else
    echo -e "Succeeded to ${@}"
  fi
}

#######################################
# Check if a list of command is present in the current context.
# Arguments:
#   ${@}: Commands to check.
# Returns:
#   0 if the command is present.
#   1 otherwise.
#######################################
function helper::commands_are_present() {
  for cmd in "${@}"; do
    if ! [ -x "$(command -v "${cmd}")" ]; then
      helper::raise_error "locate command '${cmd}'"
    fi
  done
}

#######################################
# Raise an error and exit.
# Arguments:
#   ${1}: Any textual reason.
# Returns:
#   Always exit 1.
#######################################
function helper::raise_error() {
  log::failure "$@"
  exit 1
}

#######################################
# Execute a command with arguments.
# Globals:
#   SILENT_STDOUT
#   SILENT_STDERR
# Arguments:
#   ${@}: Any arguments.
# Returns:
#   Exit status of the command executed.
#######################################
function helper::exec() {
  local silent_stdout; silent_stdout=$(env::get_or_empty "SILENT_STDOUT")
  local silent_stderr; silent_stderr=$(env::get_or_empty "SILENT_STDERR")
  local err_exit_ctx=$(shopt -o errexit)

  set +e
  if [ -z "${silent_stdout}" ] && [ -z "${silent_stderr}" ]; then
    "${@}"
  elif [ ! -z "${silent_stdout}" ] && [ ! -z "${silent_stderr}" ]; then
    "${@}" &> /dev/null
  elif [ -z "${silent_stdout}" ] && [ ! -z "${silent_stderr}" ]; then
    "${@}" 2> /dev/null
  else
    "${@}" > /dev/null
  fi
  local status=$?
  if [ $(echo "${err_exit_ctx}" | grep "on") ]; then
    set -e
  fi
  return ${status}
}

#######################################
# Try to run a command with arguments.
# Globals:
#   SILENT_STDOUT
#   SILENT_STDERR
#   CATCH_ERROR
# Arguments:
#   $1: Suffix for log success or error.
#   ${@:2}: Any arguments.
# Returns:
#   Exit status of the command executed.
#######################################
function helper::try() {
  helper::exec ${@:2}
  local status=$?
  if [ ${status} -eq 0 ]; then
    log::success "${1}"
  else
    log::failure "${1}"
    local catch_error; catch_error=$(env::get_or_empty "CATCH_ERROR")
    if [ ${status} -ne 0 ] && [ ! -z "${catch_error}" ]; then
      return 0
    else
      exit ${status}
    fi
  fi
  return ${status}
}

#######################################
# Retrive an environment variable.
# Arguments:
#   ${1}: Environment variable to get.
# Outputs:
#   Environment variable value.
# Returns:
#   0 if the environment variable is present.
#   1 otherwise.
#######################################
function env::get() {
  local var; var=$(printf '%s\n' "${!1}")
  if [ -z "${var}" ]; then
    helper::raise_error "retrieve environment '${1}' variable"
  fi
  echo -e "${var}"
}

#######################################
# Retrive an environment variable or return default value.
# Arguments:
#   ${1}: Environment variable to get.
#   ${2}: Default value.
# Outputs:
#   Environment variable value or default value.
#######################################
function env::get_or_default() {
  local var; var=$(printf '%s\n' "${!1}")
  if [ -z "${var}" ]; then
    echo -e "${2}"
  else
    echo -e "${var}"
  fi
}

#######################################
# Retrive an environment variable or return empty value.
# Arguments:
#   ${1}: Environment variable to get.
# Outputs:
#   Environment variable value or empty value.
#######################################
function env::get_or_empty() {
  env::get_or_default "${1}" ""
}

#######################################
# Retrive an environment variable or return readed value.
# Arguments:
#   ${1}: Environment variable to get.
# Outputs:
#   Environment variable value or readed value.
# Returns:
#   0 if the environment variable is present or readed.
#   1 otherwise.
#######################################
function env::get_or_read() {
  local var; var=$(printf '%s\n' "${!1}")
  if [ -z "${var}" ]; then
    read -p "Value for ${1}: `echo $'\n> '`" var
  fi
  echo -e "${var}"
}

#######################################
# Print a random char sequence suitable for id.
# Outputs:
#   Random char sequence containing alphanumeric.
#######################################
function str::random() {
  openssl rand -hex 32
}

########################################
# Run a podman container prune cleanup task.
# Arguments:
#   Container name to prune.
########################################
function podman::container_prune() {
  local podman_container_id; podman_container_id=$(podman container ls -q --filter=name=${1})
  if [ ! -z "${podman_container_id}" ]; then
    podman container kill "${podman_container_id}" > /dev/null
  fi
}

########################################
# Build a podman image based on dockerfile template.
# Globals:
#   DOCKER_BASE_IMAGE
#   DOCKER_IMAGE_TAGS
#   DOCKERFILE_PATH
# Arguments:
#   None.
########################################
function podman::build() {
  local docker_image_tag; docker_image_tag=$(env::get "DOCKER_IMAGE_TAG")
  local docker_base_image; docker_base_image=$(env::get_or_default "DOCKER_BASE_IMAGE" "debian:bookworm-slim")
  local dockerfile_path; dockerfile_path=$(env::get_or_default "DOCKERFILE_PATH" "Dockerfile.tpl")

  log::action "Generating dockerfile for project"
  local tmp_file; tmp_file="$(mktemp)"
  sed \
    -e "s/{{DOCKER_BASE_IMAGE}}/${docker_base_image}/g" \
    "${BASE_PROJECT}/${dockerfile_path}" > "${tmp_file}"
  podman build -t "ignity-${docker_image_tag}" -f "${tmp_file}" "${BASE_PROJECT}"
  local status=$?
  rm "${tmp_file}"
  return $status
}

########################################
# Run a podman container.
# Globals:
#   DOCKER_IMAGE
#   DOCKER_ARGS
#   DOCKER_CMD
# Arguments:
#   Any additional podman arguments.
# Outputs:
#   Exit status of the command executed in container.
########################################
function podman::run() {
  local docker_container_name; docker_container_name="$(str::random)"
  local docker_image; docker_image=$(env::get "DOCKER_IMAGE")

  echo "ignity-${docker_container_name}"
  podman run \
    --name "ignity-${docker_container_name}" \
    --rm \
    ${DOCKER_ARGS} \
    "${docker_image}" \
    ${DOCKER_CMD}
}

log::action "The script you are running has basename $(basename "${0}"), dirname $(dirname "${0}")"
log::action "The base project directory is ${BASE_PROJECT}"
log::action "The present working directory is $(pwd)"
