# bash_ui 
Some helpful functions for making interactive bash scripts on Linux terminal respond to cursor keys for data entry.

(and now not dependent on tput from ncurses)

[_DOWNLOAD_](https://raw.githubusercontent.com/cdrubin/bash_ui/master/bash_ui.sh)


## _select_, _multi-select_ and _select value_

----------
### Example 1 (_select_):

Allow a user to select a path


```sh

source bash_ui.sh

CHOICES=`find . -maxdepth 1 -mindepth 1 -type d -printf '%f\n'`
choose_one

echo $CHOSEN

```


---------
### Example 2 (_select multiple_):

Ask user to select from a set of options

```sh

source bash_ui.sh

CHOICES=`find . -maxdepth 1 -mindepth 1 -type d -printf '%f\n'`
choose_multiple

echo $CHOSEN

```


---------
### Example 3 (_select_):

```sh

source bash_ui.sh

read -r -d '' CHOICES <<EOT 
1. Option 1=1 
2. Yes, option 2=2 
3. Believe it or not, option 3=3 
EOT 

choose_one

if [ "$CHOSEN" == "3" ]; then 
  echo "Somehow it really was option 3 that was selected!" 
fi 
```


----------
### Example 4 (_select value_):

```sh

source bash_ui.sh

read -r -d '' CHOICES <<EOT 
one=1 
two=2
three=3
all=1\n2\n3
EOT 

choose_one

if [ ${CHOSEN} == "3" ]; then 
  echo "'three' which corresponds to value 3 was selected!" 
fi 
```

# shui

(welcome to __shui__! [DOWNLOAD](https://raw.githubusercontent.com/cdrubin/bash_ui/master/shui))

A helper script that does not need to be sourced, works in bash < 4 (hello macOS) and with Linux and Mac terminals

----------
### Example 5 (_select_)

```sh
#!/bin/bash

result=$(find /home -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | ./shui 2>&1 1>/dev/tty)
echo "Chosen home dir: $result"

```

----------
### Example 6 (_select multiple_)

```sh
#!/bin/bash

result=$(find /home -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | ./shui multiple 2>&1 1>/dev/tty)
echo "Chosen home directories:"
echo "$result"

```

----------
### Example 7 (_select multiple from provided heredoc_)

```sh
#!/bin/bash

echo "Choose your favourite characters"
read -r -d '' CHOICES <<- EOS
Roger Ellison
Duiwel Dewet
Roger Rabbit
EOS

result=$(echo -e "$CHOICES" | ./shui 2>&1 1>/dev/tty)
```
