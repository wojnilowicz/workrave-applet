#!/bin/bash

./update-mo-files.sh

cd ..
root_dir=$(pwd)

version=$(grep \"Version\" ./src/metadata.json | cut -f 2 -d: | tr -d "\", ")
basename="workrave-applet"

cd src
zip -r9 ../$basename-$version.plasmoid *
