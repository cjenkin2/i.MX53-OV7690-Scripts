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

usage()
{
	echo "usage: $0 [control] [cmd] [vals...]"
	echo "where	\"control\" is one of: $OV7690_CONTROLS"
	echo "	\"cmd\" is one of: $CMDS"
	echo "	vals... is a list of hexadecimal values (0x00 to 0xFF)"
}



get_regs()
{
	local REGS=$(eval echo \${$1}) # TODO HACK!
	for REG in $REGS
	do
		shift # I hate this language...
		${i2c_ov7690_get} $REG $1
	done
}

set_regs()
{
	local REGS=$(eval echo \${$1})
	for REG in $REGS
	do
		${i2c_ov7690_set} $REG 
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
	echo "Not yet implemented!"
	;;
esac
