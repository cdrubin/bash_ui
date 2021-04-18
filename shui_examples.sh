#! /bin/bash

result=$(find . -maxdepth 1 -mindepth 1 -type d \( -not -iname '.*' \) -printf '%f\n' | ./shui 2>&1 1>/dev/tty)
echo "Chosen directory: $result"

result=$(find . -maxdepth 1 -mindepth 1 -type d \( -not -iname '.*' \) -printf '%f\n' | ./shui multiple 2>&1 1>/dev/tty)
echo "Chosen directories: $result"