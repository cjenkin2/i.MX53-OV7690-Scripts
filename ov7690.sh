#!/bin/bash

#i2c defs
I2C_BUS="imx-i2c"
OV7690_ADDR=0x21
i2c_ov7690_get="sudo i2cget -f -y $I2C_BUS $OV7690_ADDR"
i2c_ov7690_set="sudo i2cset -f -y -r $I2C_BUS $OV7690_ADDR"

# camera control defs
# TODO bad practice - these two should be combined into one data structure
OV7690_GROUPS="AGC AEC AWB"
AGC="0x13 0x00 0x15"

# script commands
GROUP_CMDS="group_get group_set"
CMDS="get set help $GROUP_CMD"

# helper functions
unpack()
{
	eval echo \${$1}
}

num_regs_for_control()
{
	echo $(unpack $1) |  wc -w
}

get_addr()
{
	echo $1 | cut -d= -f1
}

get_val()
{
	echo $1 | cut -d= -f2
}

# proper script functions
#
usage()
{
	echo "usage: $0 [group_cmd] [group] [val...]"
	echo "       $0 get [addr...]"
	echo "       $0 set [addr=val...]"
	echo "where	\"group\" is one of: $OV7690_GROUPS"
	echo "	\"group_cmd\" is one of: $GROUP_CMDS"
	echo "	val... and addr... are lists of hexadecimal values (0x00 to 0xFF)"
}

get_regs()
{
	local REGS="$@"
	for REG in $REGS
	do
		echo "$REG:	$(${i2c_ov7690_get} $REG)"
	done
}

set_regs()
{
	local ADDR_VAL_PAIRS="$@"
	for PAIR in $ADDR_VAL_PAIRS
	do
		local REG=$(get_addr $PAIR)
		local VAL=$(get_val $PAIR)
		echo "$REG:	$(${i2c_ov7690_set} $REG $VAL)"
	done
}

get_regs_in_group()
{
	get_regs $(unpack $1)
}

set_regs_in_group()
{
	local REGS=$(unpack $1) # TODO HACK!
	for REG in $REGS
	do
		shift # I hate this language...
		echo "$REG:	$(${i2c_ov7690_set} $REG $1)"
	done
	
}

if [ $# -lt 2 ]; then
	usage
	exit 65 # bad params
fi

CMD=$1

case $CMD in
 help)
	usage
	;;
 get)
	shift; get_regs "$@" # I hate this language
	;;
 set)
	shift; set_regs "$@" # I hate this language
	;;
 group_get)
	OV7690_GROUP=$2
	get_regs_in_group $OV7690_GROUP
	;;
 group_set)
	OV7690_GROUP=$2; shift 2 # I hate this language
	if [ $# -eq $(num_regs_for_control $OV7690_GROUP) ]; then
		set_regs_in_group $OV7690_GROUP $@
	else
		echo "Error: Wrong number of params for control: $OV7690_GROUP"
		$0 $OV7690_GROUP help
	fi
	;;
esac
