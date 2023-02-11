#!/bin/bash
set -euo pipefail

function find_code {
    if [[ -z ${CODEPATH+x} ]]; then
        if [[ -d ./code ]]
        then CODEPATH=.
        else if [[ -d ../code ]]
            then CODEPATH=..
            fi
        fi
    fi
    cd $CODEPATH
    if [[ ! -d ./code ]]
    then echo "invalid CODEPATH: $PWD"
    else echo "found code at $PWD"
    fi
}

function download_rust_g {
  if [ -f "$HOME/librust_g/librust_g.so" ];
  then
    echo "Using cached rust_g."
    cp "$HOME/librust_g/librust_g.so" $PWD/librust_g.so
  else
    wget -O $PWD/librust_g.so "https://raw.githubusercontent.com/SierraBay/SierraBay12/3660bb8e0becaea80659d21a3e78b85aa9f8f890/librust_g.so"
    mkdir -p $HOME/librust_g
    cp $PWD/librust_g.so $HOME/librust_g/librust_g.so
  fi

  chmod +x $PWD/librust_g.so

  echo "Saved rust_g to $PWD/librust_g.so"
}

find_code
download_rust_g
