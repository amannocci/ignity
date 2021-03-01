#!/usr/bin/env bash
set -e

# Variables environments
readonly SKALIBS_URL="https://github.com/skarnet/skalibs.git"
readonly EXECLINE_URL="https://github.com/skarnet/execline.git"
readonly S6_URL="https://github.com/skarnet/s6.git"
readonly S6_PORTABLE_UTILS_URL="https://github.com/skarnet/s6-portable-utils.git"
readonly SKALIBS_VERSION="2.9.2.1"
readonly EXECLINE_VERSION="2.6.1.0"
readonly S6_VERSION="2.9.2.0"
readonly S6_PORTABLE_UTILS_VERSION="2.2.2.4"
BUILD_DEPENDENCIES="ca-certificates build-essential git"

# Fine tuning
export DEBIAN_FRONTEND=noninteractive

function log::action() {
  echo -e "\033[33m⇒\033[0m $*"
}

function log::failure() {
  echo -e "\033[31m✗\033[0m Failed to $*"
}

function log::success() {
  echo -e "\033[32m✓\033[0m Succeeded to $*"
}

# Notify only errors
function process::try() {
  "${@:2}"
  status="$?"
  if [ "$status" -eq 0 ]; then
    log::success "${1}"
  else
    log::failure "${1}"
    exit "$status"
  fi
}

# Compile and install dependencies
function pkg::install() {
  process::try "clone ${1} v${2}" git clone -q -b "v${2}" --depth 1 "${3}" "/tmp/${1}"
  cd "/tmp/${1}"
  process::try "configure ${1} v${2}" ./configure ${4}
  process::try "compile ${1} v${2}" make
  process::try "install ${1} v${2}" make install
}

# Diff to do iso uninstall after build
dpkg -l | awk '{print $2;}' > /tmp/before

# Install build dependencies
apt-get update > /dev/null
apt-get install --no-install-recommends -y ${BUILD_DEPENDENCIES}

# Shallow clone skalibs, execline, s6, s6-portable-utils
pkg::install "skalibs" "${SKALIBS_VERSION}" "${SKALIBS_URL}" "--enable-shared"
pkg::install "execline" "${EXECLINE_VERSION}" "${EXECLINE_URL}" "--enable-shared"
pkg::install "s6" "${S6_VERSION}" "${S6_URL}"
pkg::install "s6-portable-utils" "${S6_PORTABLE_UTILS_VERSION}" "${S6_PORTABLE_UTILS_URL}"

# Diff to do iso uninstall
dpkg -l | awk '{print $2;}' > /tmp/after
BUILD_DEPENDENCIES=$(diff /tmp/before /tmp/after | grep ">" | awk '{print $2;}')

# Purge build dependencies and cleanup apt
DEBIAN_FRONTEND=noninteractive apt-get purge -y --auto-remove ${BUILD_DEPENDENCIES}
apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

# Auto remove
rm -f /usr/src/install-ignity.sh
