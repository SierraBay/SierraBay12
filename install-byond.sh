#!/bin/sh
set -e
if [ -f ~/BYOND-${BYOND_MAJOR}.${BYOND_MINOR}/byond/bin/DreamMaker ];
then
  echo "Using cached directory."
else
  echo "Setting up BYOND."
  mkdir -p ~/BYOND-${BYOND_MAJOR}.${BYOND_MINOR}
  cd ~/BYOND-${BYOND_MAJOR}.${BYOND_MINOR}
  echo "Installing DreamMaker to $PWD"
  curl "https://dl.dropboxusercontent.com/scl/fi/mqxujy1cdgas24wtddnq7/516.1667_byond_linux.zip?rlkey=hxqo9ny8mb5kdtu0es091gseg&st=qdi1lp2c&dl=0" -o byond.zip
  unzip -o byond.zip
  cd byond
  make here
fi
