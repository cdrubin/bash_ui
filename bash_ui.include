
#
# Public function to get the current screen line number
#
# $Y will be set
#

function set_y() {
	exec < /dev/tty
	oldstty=$(stty -g)
	stty raw -echo min 0
	echo -en "\033[6n" > /dev/tty
	IFS=';' read -r -d R -a pos
	stty $oldstty
	Y=$((${pos[0]:2} - 1))
}


#
# Treat a multiline-string as an item list and determine
# whether the list $1 contains the item $2, echo'ing '1'
# if true and 0 otherwise
#

function list_contains() {

	LIST="$1"
	SEEKING="$2"

	RESULT=0

	while read -r ENTRY; do
		if [ "$ENTRY" == "$SEEKING" ]; then
			RESULT=1
		fi
	done <<< "${LIST:1}"

	echo $RESULT
}



#
# Private function used by choose to rewrite a set of lines to the screen
# $TOP should have been set by choose()
# $CHOICES is the array of choice lines
# $CHOICE_NUMBER is the currently selected choice set by choose()
#

function _choose_refresh() {
	tput cup $TOP 0
	NUM=1
	#while read -r ENTRY; do

	OLDIFS="$IFS"
	IFS=$'\n' # make newlines the token breaks
	for ENTRY in $CHOICES; do
		if [ $NUM -eq $CHOICE_NUMBER ]; then
			tput smso; echo $ENTRY; tput rmso;
		else
			tput el; echo $ENTRY
		fi
		((NUM++))
	done;
	IFS="$OLDIFS"

}


#
# $CHOICES should be a string of lines of the available choices
# $TOP will be set
# $CHOICE will be set
#

function choose_one() {
	NUMBER_OF_CHOICES=`echo "$CHOICES" | wc -l`
	CHOICE_NUMBER=1

	# print choices for the first time
	for ENTRY in $CHOICES; do
		echo $ENTRY
	done

	set_y
	TOP=$((Y - NUMBER_OF_CHOICES))

	_choose_refresh

	ESC=$(echo -en "\033")                     # define ESC
	while :;do                                 # infinite loop
		read -s -n3 KEY 2>/dev/null >&2        # read quietly three characters of input
		if [ "$KEY" == "$ESC[A" ]; then
			if [ $CHOICE_NUMBER -gt 1 ]; then ((CHOICE_NUMBER--)); fi;
			_choose_refresh
		fi

		if [ "$KEY" == "$ESC[B" ]; then
			if [ $CHOICE_NUMBER -lt $NUMBER_OF_CHOICES ]; then ((CHOICE_NUMBER++)); fi;
			_choose_refresh
		fi
		if [ "$KEY" == "$ESCM" ]; then break; fi
	done

	CHOICE=`echo "$CHOICES" | sed -n "${CHOICE_NUMBER}p"`
}



#
# updates the value of CHOSEN according to
# the items in CHOSEN_NUMBERS and the choices in
# CHOICES
#

function _update_chosen() {

	CHOSEN=""
	for i in $(seq 0 $NUMBER_OF_CHOICES); do
		for ENTRY in $CHOSEN_NUMBERS; do
			#echo $ENTRY
			if [ "$ENTRY" == "$i" ]; then
				CHOICE_LINE=`echo "$CHOICES" | sed -n "$ENTRY"P`
				CHOSEN="$CHOSEN $CHOICE_LINE"
				#echo "here"
			fi
		done
	done
}


function choose_multiple() {

	CHOICES="$CHOICES"$'\n'">"
	NUMBER_OF_CHOICES=`echo "$CHOICES" | wc -l`

	CHOICE_NUMBER=1
	CHOSEN_NUMBERS=""

	# print choices for the first time
	OLDIFS="$IFS"
	IFS=$'\n' # make newlines the token breaks
	for ENTRY in $CHOICES; do
		echo $ENTRY
	done;
	IFS="$OLDIFS"

	set_y
	TOP=$((Y - NUMBER_OF_CHOICES))

	_choose_refresh

	ESC=$(echo -en "\033")                     # define ESC
	while :;do                                 # infinite loop
		read -s -n3 KEY 2>/dev/null >&2        # read quietly three characters of input
		if [ "$KEY" == "$ESC[A" ]; then
			if [ $CHOICE_NUMBER -gt 1 ]; then ((CHOICE_NUMBER--)); fi;
			_choose_refresh
		fi

		if [ "$KEY" == "$ESC[B" ]; then
			if [ $CHOICE_NUMBER -lt $NUMBER_OF_CHOICES ]; then ((CHOICE_NUMBER++)); fi;
			_choose_refresh
		fi

		if [ "$KEY" == "$ESCM" ]; then
			if [ $CHOICE_NUMBER -eq $NUMBER_OF_CHOICES ]; then
				break;
			fi;

			if [ $(list_contains "$CHOSEN_NUMBERS" "$CHOICE_NUMBER") -eq 1 ]; then
				# remove an item line
				NEW_CHOSEN_NUMBERS=""

				while read -r ENTRY; do
					if [ "$ENTRY" != "$CHOICE_NUMBER" ]; then
						NEW_CHOSEN_NUMBERS=$(printf "$NEW_CHOSEN_NUMBERS\n$ENTRY")
					fi
				done <<< "${CHOSEN_NUMBERS:1}"

				CHOSEN_NUMBERS="$NEW_CHOSEN_NUMBERS"
			else
				# add a new item line
				CHOSEN_NUMBERS=$(printf "$CHOSEN_NUMBERS\n$CHOICE_NUMBER")

			fi

			_update_chosen

			CHOICES=`echo "$CHOICES" | sed "s/>.*/>$CHOSEN/"`
			_choose_refresh
		fi
	done

	CHOICE=`echo "$CHOICES" | sed -n "${CHOICE_NUMBER}p"`

}

