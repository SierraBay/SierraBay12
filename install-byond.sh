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
  curl "https://drive.usercontent.google.com/u/0/uc?id=1IEOIcU2kF97AtnJUkqfkf1RRdlRD0F4j&export=download" -o byond.zip
  unzip -o byond.zip
  cd byond
  make here
fi
