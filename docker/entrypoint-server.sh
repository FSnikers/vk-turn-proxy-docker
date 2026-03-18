#!/bin/sh
set -eu

if [ -z "${CONNECT_ADDR:-}" ]; then
  echo "CONNECT_ADDR is required, for example: 127.0.0.1:51820" >&2
  exit 1
fi

exec /usr/local/bin/vk-turn-server \
  -listen "${LISTEN_ADDR:-0.0.0.0:56000}" \
  -connect "${CONNECT_ADDR}" \
  "$@"
