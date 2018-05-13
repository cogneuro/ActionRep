#!/bin/bash

RDIR="/Users/dojoonyi/cn/ActionRep"
SDIR=( s01 s02 s03 s04 s05 s06 s07 s08 s09 s10 s11 s12 s14 s15 s16 s17 )

for xsn in "${SDIR[@]}"
do
	#======= Each participant
	echo '\n===========\n'
	echo $xsn
	echo '\n===========\n'

    	cd $RDIR/$xsn

	#==== 1. find outliers
	
        fsl_motion_outliers -i rexp1.nii -o dvars_rexp1.txt -p dvars_rexp1.png --dvars --nomoco -v
        fsl_motion_outliers -i rexp2.nii -o dvars_rexp2.txt -p dvars_rexp2.png --dvars --nomoco -v
        fsl_motion_outliers -i rexp3.nii -o dvars_rexp3.txt -p dvars_rexp3.png --dvars --nomoco -v
	fsl_motion_outliers -i rexp4.nii -o dvars_rexp4.txt -p dvars_rexp4.png --dvars --nomoco -v

done
