#!/bin/sh
# Called by dotfiles' install.sh after cloning/updating this repository as a module. Can also be run directly.
# Reports external tools the commands need but that are missing (does not install anything).
missing() {  # missing <command> <used by> <how to install>
  command -v "$1" >/dev/null 2>&1 || printf '  ! %s not found (used by %s): %s\n' "$1" "$2" "$3"
}
if [ "$(uname -s)" = Darwin ]; then
  missing pandoc md "brew install pandoc"
  missing typst "md -p" "brew install typst"
  missing gcc "crun / cprun" "xcode-select --install"
else
  missing pandoc md "sudo apt install pandoc"
  missing typst "md -p" "https://github.com/typst/typst/releases"
  missing gcc "crun / cprun" "sudo apt install build-essential"
fi
missing zsh "md / ch" "preinstalled on macOS; on Linux: sudo apt install zsh"
exit 0
