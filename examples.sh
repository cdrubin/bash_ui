#! /bin/bash

source bash_ui.sh

CHOICES=`find . -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | sort`

choose_one
echo "$CHOICE was chosen"
echo

choose_multiple
echo "$CHOSEN were chosen"
echo "$CHOSEN_LINES lines were chosen"
echo

CHOICES=`cat hij.txt`

choose_one_value
echo "$CHOICE which corresponds to value $CHOICE_VALUE was chosen"
echo $VALUES