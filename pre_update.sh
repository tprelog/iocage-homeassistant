#!/usr/bin/env bash

. /etc/rc.subr && load_rc_config

# shellcheck disable=SC2154
version=$(echo "${plugin_version%%-*}" | cut -c2-)

if ! [ "${version:-0}" -ge 6 ]; then
  warn "  Unknown or unsupported version detected. Manual intervention required! "
  err 1 " You must reinstall the plugin to perform this upgrade. "
fi
