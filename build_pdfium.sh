#! /bin/bash

# if want to run this from somewhere other then /data adjust below
basedir=/home/pdfium/data

# exit when any command fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

apt-get update

apt-get install -y  build-essential git subversion pkg-config python libtool cmake glib2.0-dev libatspi2.0-dev wget lsb-release sudo

cd $basedir

mkdir -p build/source

if [ ! -e depot_tools ]; then
	git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
fi

export PATH=$PATH:$basedir/depot_tools/

cd build/source/

gclient config --unmanaged https://pdfium.googlesource.com/pdfium.git

echo "target_os = [ 'android' ]" >> .gclient

gclient sync

cd pdfium
./build/install-build-deps.sh

gclient runhooks