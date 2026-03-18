#!/bin/sh
set -eu

if [ -z "${PEER_ADDR:-}" ]; then
  echo "PEER_ADDR is required, for example: 203.0.113.10:56000" >&2
  exit 1
fi

if [ -z "${VK_LINK:-}" ] && [ -z "${YANDEX_LINK:-}" ]; then
  echo "Either VK_LINK or YANDEX_LINK must be set" >&2
  exit 1
fi

set -- /usr/local/bin/vk-turn-client \
  -peer "${PEER_ADDR}" \
  -listen "${LISTEN_ADDR:-0.0.0.0:51820}"

if [ -n "${VK_LINK:-}" ]; then
  set -- "$@" -vk-link "${VK_LINK}"
fi

if [ -n "${YANDEX_LINK:-}" ]; then
  set -- "$@" -yandex-link "${YANDEX_LINK}"
fi

if [ "${TRANSPORT_MODE:-tcp}" = "udp" ]; then
  set -- "$@" -udp
fi

if [ -n "${TURN_HOST:-}" ]; then
  set -- "$@" -turn "${TURN_HOST}"
fi

if [ -n "${TURN_PORT:-}" ]; then
  set -- "$@" -port "${TURN_PORT}"
fi

if [ -n "${CONNECTIONS:-}" ]; then
  set -- "$@" -n "${CONNECTIONS}"
fi

if [ "${NO_DTLS:-false}" = "true" ]; then
  set -- "$@" -no-dtls
fi

exec "$@"
