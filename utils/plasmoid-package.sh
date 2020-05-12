#!/bin/bash

cd ..
root_dir=$(pwd)

version=$(grep Version ./src/metadata.desktop | cut -f2 -d'=')
basename="workrave-applet"

cd src
zip -r9 ../$basename-$version.plasmoid *