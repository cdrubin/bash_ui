#! /bin/bash

result=$(find . -maxdepth 1 -mindepth 1 -type d \( -not -iname '.*' \) -printf '%f\n' | ./shui clean 2>&1 1>/dev/tty)
echo "Chosen directory: $result"

result=$(find . -maxdepth 1 -mindepth 1 -type d \( -not -iname '.*' \) -printf '%f\n' | ./shui multiple 2>&1 1>/dev/tty)
echo "Chosen directories: $result"


read -r -d '' CHOICES <<- EOS
a longer option here and in fact one that goes past the end of the line. Yes really these sorts of things have been known to happen!
two
three
all
EOS

result=$(echo -e "$CHOICES" | ./shui 2>&1 1>/dev/tty)
