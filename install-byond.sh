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
  curl "https://dl.dropboxusercontent.com/scl/fi/qjagyg84zd1phiqpb0aqj/516.1666_byond_linux.zip?rlkey=a317estcgdrbeilzrrx3xkegs&st=oyu7f24g&dl=0" -o byond.zip
  unzip -o byond.zip
  cd byond
  make here
fi
