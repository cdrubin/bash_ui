#! /bin/bash

source bash_ui.sh

CHOICES=`find . -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | sort`

choose_one
echo "$CHOSEN was chosen"
echo

choose_multiple
echo "$CHOSEN were chosen"
echo



CHOICES=`cat hij.txt`

choose_one
echo "$CHOSEN was chosen"
echo

choose_multiple
echo "$CHOSEN was chosen"
echo