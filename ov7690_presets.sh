#!/bin/bash

. ./ov7690_reg_funcs.sh


usage()
{
	echo "usage:	$0 set [preset]"
	echo "	$0 view [preset]"
	echo "where	preset is one of: $PRESETS"
}

# list of all presets
# TODO these should be more tightly connected!
PRESETS="DEFAULT LOW_CHROMA_HIGH_EXP LOW_CHROMA_6R7_FPS QVGA_G1_5"

# 	reset regs	best edge
DEFAULT="0x12=0x80 	0xB4=0x0F"

# solution 1 to high chroma noise: high exposure low fps
#		    manual EC	clock: 1r4		high exposure
LOW_CHROMA_HIGH_EXP="0x13=0xf6	0x11=0x03 0x29=0xD0	0x0F=0x02 0x10=0xFF"

# solution 2 to high chroma noise: exposure when PCLK = 6r7 * XCLK
#				clock: 6r7
LOW_CHROMA_6R7_FPS="0x13=0xf6	0x11=0x01 0x29=0xA0	0x0F=0x02 0x10=0xFF"

# QVGA from g1-5 Android device
QVGA_G1_5="0x16=0x03 0x17=0x69 0x18=0xa4 0x19=0x06 0x1a=0xf6 0x22=0x10" 
QVGA_G1_5="${QVGA_G1_5} 0xc8=0x02 0xc9=0x80 0xca=0x00 0xcb=0xf0 0xcc=0x01" 
QVGA_G1_5="${QVGA_G1_5} 0xcd=0x40 0xce=0x00 0xcf=0xf0"

# function definition
#
set_preset() # assumes parameter is sane
{
	local PRESET=$1
	set_regs $(unpack $PRESET)
}

view_preset()
{
	local PRESET=$1
	
	echo "addr=val"
	for PAIR in $(unpack $PRESET)
	do
		echo $PAIR
	done
}

# parameter check
if [ $# -ne 2 ]; then
	usage
	exit 65 # bad params
fi

CMD=$1
PRESET=$2

if [ -z "$(unpack $PRESET)" ]; then
	echo "Error: $PRESET is not a valid camera presetting"
	usage
	exit 1
fi


case $CMD in 
  set)
	set_preset $PRESET
	;;
  view)
	view_preset $PRESET
	;;
  *)
	echo "Error: unrecognized command: $CMD"
	usage
	exit 1
	;;
esac
