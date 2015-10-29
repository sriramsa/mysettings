#!/usr/bin/env bash

# Compiling VIM with lua support

./configure --with-features=huge --enable-rubyinterp=yes --enable-pythoninterp=yes --enable-luainterp=yes --enable-cscope --enable-largefile --enable-gui=gnome2 --with-python-config-dir=/usr/lib/python2.7/config-x86_64-linux-gnu --enable-fail-if-missing --enable-python3interp=yes

make VIMRUNTIMEDIR=/usr/local/share/vim/vim74
sudo make install
