#!/bin/bash
set -euo pipefail

if [ -f "$HOME/librust_g/librust_g.so" ];
then
  echo "Using cached rust_g."
  cp "$HOME/librust_g/librust_g.so" ~/librust_g.so
else
  wget -O ~/librust_g.so "https://raw.githubusercontent.com/SierraBay/SierraBay12/3660bb8e0becaea80659d21a3e78b85aa9f8f890/librust_g.so"
  mkdir -p $HOME/librust_g
  cp ~/librust_g.so $HOME/librust_g/librust_g.so
fi

chmod +x ~/librust_g.so

echo "librust_g.so OK"
