#!/usr/bin/env bash

# Found current script directory
RELATIVE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Load common
# shellcheck disable=SC1090
source "${RELATIVE_DIR}/../../scripts/lib.sh"

# Constants
FILENAME=${BASE_PROJECT}/.git/${1##*/}

# Validate commit message prefix
test "" != "$(grep -E '^(build|ci|docs|feat|fix|perf|refactor|test|chore)' "${FILENAME}")" || {
  log::failure "validate prefix in commit message (build|ci|docs|feat|fix|perf|refactor|test|chore)"
  exit 1
}
log::success "check commit message"

exit 0
