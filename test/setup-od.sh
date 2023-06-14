#!/bin/bash
set -eo pipefail

if [ -f "$HOME/OpenDream/OpenDream.sln" ];
then
  echo "Using cached directory."
else
  echo "Setting up OpenDream."
  git clone https://github.com/OpenDreamProject/OpenDream.git $HOME/OpenDream
  git -C $HOME/OpenDream submodule update --init --recursive
  dotnet restore $HOME/OpenDream
  dotnet build $HOME/OpenDream/OpenDream.sln -c Release --property WarningLevel=1
