#!/bin/zsh
# description: Open files/URLs in Google Chrome (instead of default browser)

usage() {
  echo "Usage: ch [file|url] ..."
  echo "  no args: open Chrome itself"
  exit 1
}

case "$1" in
  -h|--help) usage ;;
esac

if [ $# -eq 0 ]; then
  open -a "Google Chrome"
else
  open -a "Google Chrome" "$@"
fi
