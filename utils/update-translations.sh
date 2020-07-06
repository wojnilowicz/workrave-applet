#!/bin/bash

cd ..
root_dir=$(pwd)
msg_basename="plasma_applet_org.kde.workraveApplet"

cd utils
extract_messages_script="scripts/extract-messages.sh"
if [ ! -f $extract_messages_script ]; then
  svn checkout svn://anonsvn.kde.org/home/kde/trunk/l10n-kf5/scripts
fi

cd $root_dir
PATH=./utils/scripts:$PATH bash ./utils/$extract_messages_script

cd po
find . -iname *.po -exec msgmerge --update --backup=none --previous {} $msg_basename.pot \;

language_codes=$(find . -maxdepth 1 -type d ! -path . -printf "%f\n")

cd $root_dir
for language_code in ${language_codes[@]}; do
  mo_directory="./src/contents/locale/$language_code/LC_MESSAGES"
  po_directory="./po/$language_code"
  mkdir -p ./src/contents/locale/$language_code/LC_MESSAGES
  msgfmt --no-hash -o $mo_directory/$msg_basename.mo $po_directory/$msg_basename.po
done
