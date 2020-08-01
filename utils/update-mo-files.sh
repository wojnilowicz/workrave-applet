#!/bin/bash

cd ..
root_dir=$(pwd)
msg_basename="plasma_applet_org.kde.workraveApplet"

cd po

language_codes=$(find . -maxdepth 1 -type d ! -path . -printf "%f\n")

cd $root_dir
for language_code in ${language_codes[@]}; do
  mo_directory="./src/contents/locale/$language_code/LC_MESSAGES"
  po_directory="./po/$language_code"
  mkdir -p ./src/contents/locale/$language_code/LC_MESSAGES
  msgfmt --no-hash -o $mo_directory/$msg_basename.mo $po_directory/$msg_basename.po
done
