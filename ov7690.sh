#!/bin/bash

#i2c defs
I2C_BUS="imx-i2c"
OV7690_ADDR=0x21
i2c_ov7690_get="sudo i2cget -f -y $I2C_BUS $OV7690_ADDR"
i2c_ov7690_set="sudo i2cset -f -y -r $I2C_BUS $OV7690_ADDR"

# camera control defs
# TODO bad practice - these two should be combined into one data structure
OV7690_CONTROLS="AGC AEC AWB"
AGC="0x13 0x00 0x15"

# script commands
CMDS="get set help"

# helper functions
unpack()
{
	eval echo \${$1}
}

num_regs_for_control()
{
	echo $(unpack $1) |  wc -w
}

# proper script functions
usage()
{
	echo "usage: $0 [control] [cmd] [vals...]"
	echo "where	\"control\" is one of: $OV7690_CONTROLS"
	echo "	\"cmd\" is one of: $CMDS"
	echo "	vals... is a list of hexadecimal values (0x00 to 0xFF)"
}



get_regs()
{
	local REGS=$(unpack $1) # TODO HACK!
	for REG in $REGS
	do
		echo "$REG:	$(${i2c_ov7690_get} $REG)"
	done
}

set_regs()
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

OV7690_CONTROL=$1
CMD=$2

case $CMD in
 help)
	usage; echo ""
	echo "	Registers for $OV7690_CONTROL: $(eval echo \${$OV7690_CONTROL})"
	;;
 get)
	get_regs $OV7690_CONTROL
	;;
 set)
	shift 2
	if [ $# -eq $(num_regs_for_control $OV7690_CONTROL) ]; then
		set_regs $OV7690_CONTROL $@
	else
		echo "Error: Wrong number of params for control: $OV7690_CONTROL"
		$0 $OV7690_CONTROL help
	fi
	;;
esac
