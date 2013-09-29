#!/bin/bash

. ./ov7690_reg_funcs.sh

usage()
{
	echo "usage: $0 get [addr...]"
	echo "       $0 group_get [group]"
	echo "       $0 set [addr=val...]"
	echo "where  addr... and val... are lists of hexadecimal values (0x00 to 0xFF)"
	echo "       group is one of: ${OV7690_GROUPS}"
}

# parameter check
if [ $# -lt 2 ]; then
	usage
	exit 65 # bad params
fi

# function dispatch
CMD=$1
case $CMD in
 help)
	usage
	;;
 get)
	shift; get_regs "$@" # I hate this language
	;;
 group_get)
	OV7690_GROUP=$2
	get_regs_in_group $OV7690_GROUP
	;;
 set)
	shift; set_regs "$@" # I hate this language
	;;
 *)
	echo "Error: unknown command:	$CMD"
	usage
	;;
esac
