#!/bin/bash

set -eux -o pipefail

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR=$(dirname "${SCRIPTPATH}")

# download_envoy downloads the envoy binary used in maistra/istio repository
function download_envoy() {
  [ -n "${ENVOY_BINARY:-}" ] && return

  ISTIO_REPO="${ISTIO_REPO:-maistra/istio}"
  ISTIO_BRANCH="${ISTIO_BRANCH:-$(git symbolic-ref --quiet --short HEAD)}"
  PROXY_SHA=$(curl -sL "https://raw.githubusercontent.com/${ISTIO_REPO}/${ISTIO_BRANCH}/istio.deps" | grep lastStableSHA | cut -f 4 -d '"')

  # curl below gives us a string like ISTIO_ENVOY_BASE_URL="${ISTIO_ENVOY_BASE_URL:-https://storage.googleapis.com/istio-build/proxy}"
  # eval() below should then define the variable ISTIO_ENVOY_BASE_URL, which is used below.
  eval "$(curl -sL "https://raw.githubusercontent.com/${ISTIO_REPO}/${ISTIO_BRANCH}/bin/init.sh" | grep 'ISTIO_ENVOY_BASE_URL=')"
  ENVOY_URL="${ISTIO_ENVOY_BASE_URL}/envoy-alpha-${PROXY_SHA}.tar.gz"

  curl -sL "${ENVOY_URL}" | tar zx -C "${DIR}" --strip=3
  ENVOY_BINARY="${DIR}/envoy"
}

# run_envoy runs the envoy process in background
function run_envoy() {
  cp "${ROOTDIR}/plugin.wasm" "${SCRIPTPATH}"
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
  [ -n "${ENVOY_PID:-}" ] && kill "${ENVOY_PID}"
  rm -rf "${DIR}"
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

main
