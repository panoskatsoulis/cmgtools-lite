#!/bin/bash

{ [ "$1" == "--help" ] || [ "$1" == "" ]; } && {
    echo "Usage urlToBashLink.sh <cmd> <dir>"
    echo "cmds: make, clean"
    echo
    exit 0
}

# arguments
cmd=$1
dir=$2
cd $dir

# cmd make
if [ "$cmd" == "make" ]; then
    for url in $(ls */*url); do
	link=`echo $url | sed s/.url//`
	file=`cat $url | sed -r "s@root://eosuser.cern.ch[/]+(.*)@/\1@"`
	ln -s $file $link || { echo "ln failed for $link"; exit 1; }
    done
    echo "Links that have been created under $PWD:"
    for file in `find .`; do [ -h $file ] && echo $file; done
fi

# cmd clean
if [ "$cmd" == "clean" ]; then
    for link in $(ls */*root); do
	[ -h $link ] && rm $link
    done
    echo "Links that still exist under $PWD:"
    for file in `find .`; do [ -h $file ] && echo $file; done
fi

cd - > /dev/null
exit 0
