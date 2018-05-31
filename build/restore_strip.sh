#!/bin/bash

if [ ! -f "/usr/bin/strip.bak" ]; then
  echo "[strip] You don't have a file to restore strip"

else
  if [[ "$(file -bik "$(readlink /usr/bin/strip)")" != *shell* ]]; then
    echo "[strip] It seems to normal strip in your system."
    strip --help

  else
    sudo rm "/usr/bin/strip"
    sudo mv "/usr/bin/strip.bak" "/usr/bin/strip"
    echo "[strip] Done!"
    ls -l /usr/bin/strip
    strip --help
  fi

fi

