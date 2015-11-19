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

echo $CHOSEN

```


---------
###Example 2:

Ask user to select from a set of options

```sh

source bash_ui.sh

CHOICES=`find . -maxdepth 1 -mindepth 1 -type d -printf '%f\n'`
choose_mulitple

echo $CHOSEN
echo $CHOSEN_LINES

```
