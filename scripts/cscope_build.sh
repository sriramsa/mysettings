#!/bin/bash

set -x
CURR_DIR=`pwd`
find . -iname "*.[ch]" >cscope.files
find . -iname "*.cpp" >>cscope.files
find . -iname "*.hpp" >>cscope.files
find . -iname "*.idl" >>cscope.files
find . -iname "*.mk" >>cscope.files
find . -iname "*.inc" >>cscope.files

cscope -b -i cscope.files -f cscope.out


nmap <F10> :!find . -iname '*.c' -o -iname '*.cpp' -o -iname '*.h' -o -iname '*.hpp' > cscope.files<CR>
  \:!cscope -b -i cscope.files -f cscope.out<CR>
  \:cs reset<CR>
