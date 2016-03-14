#!/usr/bin/env bash
# Build cscope index for C/C++ files

set -x

# Functions
function fn_add_files {
    find $1 -iname "*.[ch]" >>cscope.files
    find $1 -iname "*.cpp" >>cscope.files
    find $1 -iname "*.hpp" >>cscope.files
    find $1 -iname "*.idl" >>cscope.files
    find $1 -iname "*.mk" >>cscope.files
    find $1 -iname "*.inc" >>cscope.files
}

# Main
find /usr/include -iname "*.[ch]" >cscope.files
find /usr/include -iname "*.hpp" >>cscope.files
find /usr/include/c++ -type f >>cscope.files

fn_add_files `pwd`
#find /home/sriramsh/src/github.com/sriramsa/collectd -name *.[ch] >>cscope.files

# Get the directories specified
while test $# -gt 0
do
    fn_add_files $1
    shift
done


#cscope -b -i cscope.files -f cscope.out
cscope -b -q -i cscope.files


#nmap <F10> :!find . -iname '*.c' -o -iname '*.cpp' -o -iname '*.h' -o -iname '*.hpp' > cscope.files<CR>
#  \:!cscope -b -i cscope.files -f cscope.out<CR>
#  \:cs reset<CR>
