#!/usr/bin/env bash

. /etc/rc.subr && load_rc_config

# shellcheck disable=SC2154
ver="${plugin_version%%-*}"

if [[ "${ver:1:2}" -lt 6 ]]; then
  warn "  Unknown or unsupported version detected. Manual intervention required! "
  err 1 " You must reinstall the plugin to perform this upgrade. "
fi
