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
PRESETS="DEFAULT QVGA_G1_5" 					 # output
PRESETS="$PRESETS EXP_FPS_1R4 EXP_FPS_4R5 EXP_FPS_6R7" 		 # fps
PRESETS="$PRESETS AWB_CLOUDY AWB_CLEAR AWB_TUNGSTEN AWB_DEFAULT" # white balance

# 	reset regs	best edge
DEFAULT="0x12=0x80 	0xB4=0x0F"

# high chroma noise
#

# solution 1: high exposure low fps
#	     clock: 1r4			high exposure
EXP_FPS_1R4="0x11=0x03 0x29=0xD		0x0F=0x02 0x10=0xFF"

# solution 2: exposure when PCLK = 6r7 * XCLK
#	     clock: 6r7
EXP_FPS_6R7="0x11=0x06 0x29=0x20	0x0F=0x02 0x10=0xFF"

# solution 3: exposure when PCLK = 4r5 * XCLK
#	     clock: 4r5
EXP_FPS_4R5="0x11=0x4 0x29=0x10		0x0F=0x02 0x10=0xFF"

# color filters
#
AWB_CLOUDY="0x01=0x40 0x02=0x5d 0x03=0x40"
AWB_CLEAR="0x01=0x44 0x02=0x55 0x03=0x40"
AWB_TUNGSTEN1="0x01=0x5b 0x02=0x4c 0x03=0x40"
AWB_DEFAULT="0x01=0x8e 0x02=0xb2 0x03=0x80"

# QVGA from g1-5 Android device
QVGA_G1_5="0x16=0x03 0x17=0x69 0x18=0xa4 0x19=0x06 0x1a=0xf6 0x22=0x10" 
QVGA_G1_5="${QVGA_G1_5} 0xc8=0x02 0xc9=0x80 0xca=0x00 0xcb=0xf0 0xcc=0x01" 
QVGA_G1_5="${QVGA_G1_5} 0xcd=0x40 0xce=0x00 0xcf=0xf0"


# function definition
#

# assumes parameter is sane
set_preset()
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
