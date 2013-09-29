#!/bin/bash

#i2c defs
I2C_BUS="imx-i2c"
OV7690_ADDR=0x21
i2c_ov7690_get="sudo i2cget -f -y $I2C_BUS $OV7690_ADDR"
i2c_ov7690_set="sudo i2cset -f -y -r $I2C_BUS $OV7690_ADDR"

# OOP by naming conventions... disgusting
#

#OV7690_GROUP object names
OV7690_GROUPS="AGC AEC AWB LENS CLOCK"

#OV7690_GROUP object registers
AGC="0x13 0x00 0x15 0x14 0xBA"
AWB="0x13 0x01 0x02 0x03"
AEC="0x13 0x0F 0x10 0x20 0x21"
LENS="0x80"
CLOCK="0x11 0x29"

# helper functions
unpack()
{
	eval echo \${$1}
}

# for extracting addr=val
get_addr()
{
	echo $1 | cut -d= -f1
}

get_val()
{
	echo $1 | cut -d= -f2
}

get_regs()
{
	local REGS="$@"
	
	echo "addr	value"
	for REG in $REGS
	do
		echo "$REG:	$(${i2c_ov7690_get} $REG)"
	done
}

get_regs_in_group()
{
	get_regs $(unpack $1)
}

set_regs()
{
	local ADDR_VAL_PAIRS="$@"

	echo "addr	action"
	for PAIR in $ADDR_VAL_PAIRS
	do
		local REG=$(get_addr $PAIR)
		local VAL=$(get_val $PAIR)
		echo "$REG:	$(${i2c_ov7690_set} $REG $VAL)"
	done
}
