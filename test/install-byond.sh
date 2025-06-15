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
<<<<<<< ours
  curl "https://storage.chaotictapok.ru/BYOND/516.1662_byond_linux.zip" -o byond.zip
=======
  curl "https://indm.dev/byond/${BYOND_MAJOR}/${BYOND_MAJOR}.${BYOND_MINOR}_byond_linux.zip" -o byond.zip
>>>>>>> theirs
  unzip -o byond.zip
  cd byond
  make here
fi
