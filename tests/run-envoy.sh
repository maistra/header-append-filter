#!/bin/bash

set -eux -o pipefail

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR=$(dirname "${SCRIPTPATH}")

# download_envoy downloads the envoy binary used in maistra/istio repository
function download_envoy() {
  [ -n "${ENVOY_BINARY:-}" ] && return

  ISTIO_BRANCH="${ISTIO_BRANCH:-$(git symbolic-ref --quiet --short HEAD)}"
  PROXY_SHA=$(curl -sL "https://raw.githubusercontent.com/maistra/istio/${ISTIO_BRANCH}/istio.deps" | grep lastStableSHA | cut -f 4 -d '"')
  ENVOY_BASE_URL=$(curl -sL "https://raw.githubusercontent.com/maistra/istio/${ISTIO_BRANCH}/Makefile.core.mk" | grep 'export ISTIO_ENVOY_BASE_URL' | awk '{print $4}')
  ENVOY_URL="${ENVOY_BASE_URL}/envoy-alpha-${PROXY_SHA}.tar.gz"

  curl -sL "${ENVOY_URL}" | tar zx -C "${DIR}" --strip=4
  ENVOY_BINARY="${DIR}/envoy"
}

# run_envoy runs the envoy process in background
function run_envoy() {
  cp "${ROOTDIR}/extension.wasm" "${SCRIPTPATH}"
  "${ENVOY_BINARY}" -c ./tests/envoy.yaml --concurrency 2 --log-format '%v' &
  ENVOY_PID=$!
  sleep 5
}

function run_test() {
  local output=

  output="$(curl -sI localhost:18000/)"
  echo "${output}" | grep "header-one: value one"
  echo "${output}" | grep "another-header: another value"
}

function finish() {
  rm -rf "${DIR}"
  [ -n "${ENVOY_PID:-}" ] && kill "${ENVOY_PID}"
}

function prepare() {
  DIR=$(mktemp -d)
  trap finish EXIT
}


function main() {
  prepare
  download_envoy
  run_envoy
  run_test
}
echo $XUXA
main
