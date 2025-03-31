#!/bin/bash

sudo rm -rf /etc/apt/sources.list.d
sudo bash -c "curl -skL https://git.kejizero.online/zhao/files/raw/branch/main/Rely/sources-24.04.list > /etc/apt/sources.list"
sudo apt-get update
sudo apt-get install -y build-essential flex bison cmake g++ gawk gcc-multilib g++-multilib gettext git gnutls-dev libfuse-dev libncurses5-dev libssl-dev python3 python3-pip python3-ply python3-pyelftools rsync unzip zlib1g-dev file wget subversion patch upx-ucl autoconf automake curl asciidoc binutils bzip2 lib32gcc-s1 libc6-dev-i386 uglifyjs msmtp texinfo libreadline-dev libglib2.0-dev xmlto libelf-dev libtool autopoint antlr3 gperf ccache swig coreutils haveged scons libpython3-dev rename qemu-utils jq