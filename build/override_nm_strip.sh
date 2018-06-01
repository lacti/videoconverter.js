#!/bin/bash

pushd "$(dirname "$(which llvm-nm)")" > /dev/null

echo "[nm] check nm."
if [ ! -f "nm" ]; then
  ln -s llvm-nm nm
fi
echo "[nm] $(which nm)"

echo "[strip] check strip."
if [[ "$(file -bik "$(readlink /usr/bin/strip)")" == *shell* ]]; then
  echo "[strip] $(strip --help)"
else
  if [ ! -f "strip" ]; then
    echo -e '#!/bin/bash\necho "No strip: $@"' > strip
    chmod +x strip
    echo "[strip] $(which strip)"
  fi

  if [ -f "/usr/bin/strip" ]; then
    sudo mv "/usr/bin/strip" "/usr/bin/strip.bak"
    sudo ln -s "$(which strip)" "/usr/bin/strip"

    echo "[strip] $(which strip)"
    echo "[strip] $(file -bik "$(readlink /usr/bin/strip)")"
    echo "[strip] $(strip --help)"

    echo ""
    echo "Caution!"
    echo "  /usr/bin/strip is renamed to strip.bak"
    echo "  Do not forget to run \"restore_strip.sh\" after building."
  fi

fi

popd > /dev/null

