#!/bin/bash

cd ..
root_dir=$(pwd)
msg_basename="plasma_applet_org.kde.workraveApplet"

cd utils
extract_messages_script="scripts/extract-messages.sh"
if [ ! -f $extract_messages_script ]; then
  svn checkout svn://anonsvn.kde.org/home/kde/trunk/l10n-kf5/scripts
fi

if [ -f $extract_messages_script ]; then
  sed -i s+"https://bugs.kde.org"+"https://github.com/wojnilowicz/workrave-applet/issues"+g $extract_messages_script
  export PACKAGE="workrave-applet"
fi

cd $root_dir
PATH=./utils/scripts:$PATH bash ./utils/$extract_messages_script

cd po
find . -iname *.po -exec msgmerge --update --backup=none --previous {} $msg_basename.pot \;