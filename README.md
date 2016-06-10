# bash_ui
Some helpful functions for making interactive bash scripts on Linux terminal respond to cursor keys for data entry.


## select and multi-select

----------
### Example 1:

Allow a user to select a path


```sh

source bash_ui.sh

CHOICES=`find . -maxdepth 1 -mindepth 1 -type d -printf '%f\n'`
choose_one

echo $CHOICE

```


---------
###Example 2:

Ask user to select from a set of options

```sh

source bash_ui.sh

CHOICES=`find . -maxdepth 1 -mindepth 1 -type d -printf '%f\n'`
choose_multiple

echo $CHOSEN
echo $CHOSEN_LINES

```


---------
###Example 3:

```sh

source bash_ui.sh

read -r -d '' CHOICES <<EOT 
1. Option 1 
2. Yes, option 2 
3. Believe it or not, option 3 
EOT 

choose_one

if [ ${CHOICE:0:1} == "3" ]; then 
  echo "Somehow it really was option 3 that was selected!" 
fi 
