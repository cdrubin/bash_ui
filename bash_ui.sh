# MIT license, explained here:
#   http://www.tldrlegal.com/l/mit

# Copyright (c) 2020 Cefan Daniel Rubin
#
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Latest:
#   https://github.com/cdrubin/bash_ui


if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    echo "bash_ui.sh requires bash version 4 or greater"
    exit
fi


declare -A _CHOICES
declare _CHOICES_ORDER
declare _NUMBER_OF_CHOICES
declare _HIGHLIGHTED_CHOICE


function _initialise() {

    local CHOICE_NUMBER=0
    local PARTS=''
    _CHOICES=()
    _CHOICES_ORDER=()
    #unset _CHOICES; declare -A _CHOICES
    #unset _CHOICES_ORDER; declare _CHOICES_ORDER
    local IFS=$'\n';
    for ENTRY in $CHOICES; do
        IFS='=' PARTS=( $ENTRY )
        local KEY="${PARTS[0]}"; local VALUE="${PARTS[1]}"
        if [ "$VALUE" == "" ]; then VALUE="$KEY"; fi
        
        _CHOICES["$KEY"]=$VALUE
        _CHOICES_ORDER+=( "$KEY" )
    done

    _NUMBER_OF_CHOICES="${#_CHOICES[@]}"
}


function set_y() {
    exec < /dev/tty
    local OLDSTTY=$(stty -g)
    stty raw -echo min 0
    echo -en "\033[6n" > /dev/tty
    IFS=';' read -r -d R -a pos
    stty $OLDSTTY
    _Y=$((${pos[0]:2} - 1))
}


function _choose_refresh() {
    echo -e "\033[${_TOP};0H"
    local NUM=1
        
    for ENTRY in "${_CHOICES_ORDER[@]}"; do
        if [ $NUM -eq $_HIGHLIGHTED_CHOICE ]; then
            echo -n -e "\033[7m"; echo -n "$ENTRY"; echo -e "\033[0m"
        else
            echo -n -e "\033[K"; echo $ENTRY
        fi
        ((NUM++))
    done
}


# if CHOSEN key has a value with newlines (when refer to multiple keys) then update CHOSEN to all of those keys
function _chosen_handle_multiple_valuekeys() {

    local KEY="$CHOSEN"
    local VALUE=${_CHOICES[$KEY]}
    
    # if the value at this key contains newlines then convert to an array of keys
    if [[ "$VALUE" == *"\n"* ]]; then
        
        local DELIMITER="\n"
        local ORIG=$VALUE$DELIMITER
        
        CHOSEN=()
        while [[ $ORIG ]]; do
            CHOSEN+=( "${ORIG%%"$DELIMITER"*}" );
            ORIG=${ORIG#*"$DELIMITER"};
        done;
    fi
}


# convert a single key or array of keys to their corresponding values
function _chosen_keys_to_values() {

    local KEYS="${CHOSEN[@]}"
        
    CHOSEN=()
    local IFS=$'\n'
    for KEY in ${KEYS[@]}; do
        CHOSEN+=( ${_CHOICES[$KEY]} )
    done;
}


function _chosen_to_newlines_output() {

    local OUTPUT
    
    printf -v OUTPUT  "%s\n" "${CHOSEN[@]}"
    CHOSEN=${OUTPUT%?}
}


function choose_one() {

    _initialise
    
    _HIGHLIGHTED_CHOICE=1
    
    for ENTRY in "${_CHOICES_ORDER[@]}"; do
        echo $ENTRY
    done

    set_y
    _TOP=$((_Y - _NUMBER_OF_CHOICES))

    _choose_refresh

    # kwy handling thanks to: https://stackoverflow.com/a/56200043
    while read -sn1 key; do

        read -sn1 -t 0.0001 k1; read -sn1 -t 0.0001 k2; read -sn1 -t 0.0001 k3
        key+=${k1}${k2}${k3}

        case "$key" in
            $'\e[A'|$'\e0A')  # up arrow
                if [ $_HIGHLIGHTED_CHOICE -gt 1 ]; then ((_HIGHLIGHTED_CHOICE--)); fi; _choose_refresh;;

            $'\e[B'|$'\e0B')  # down arrow
                if [ $_HIGHLIGHTED_CHOICE -lt $_NUMBER_OF_CHOICES ]; then ((_HIGHLIGHTED_CHOICE++)); fi; _choose_refresh;;

            '')  # whitespace character
                break
        esac
    done

    # CHOSEN set to the selected key
    CHOSEN=${_CHOICES_ORDER[((_HIGHLIGHTED_CHOICE-1))]}

    _chosen_handle_multiple_valuekeys
    _chosen_keys_to_values
    _chosen_to_newlines_output
}


function choose_multiple() {

    _initialise

    _HIGHLIGHTED_CHOICE=1
    
    # add 'submit' faux last choice
    _CHOICES_ORDER+=( ">" )
    ((_NUMBER_OF_CHOICES++))

    # associative array, indexed by choice key, when set it has been selected
    declare -A CHOSEN_KEYS
    
    # print choices for the first time
    for ENTRY in "${_CHOICES_ORDER[@]}"; do
        echo "$ENTRY"
    done
    
    set_y
    _TOP=$((_Y - _NUMBER_OF_CHOICES ))

    _choose_refresh

        # kwy handling thanks to: https://stackoverflow.com/a/56200043
    while read -sn1 key; do

        read -sn1 -t 0.0001 k1; read -sn1 -t 0.0001 k2; read -sn1 -t 0.0001 k3
        key+=${k1}${k2}${k3}

        case "$key" in
            $'\e[A'|$'\e0A')  # up arrow
                if [ $_HIGHLIGHTED_CHOICE -gt 1 ]; then ((_HIGHLIGHTED_CHOICE--)); fi; _choose_refresh;;

            $'\e[B'|$'\e0B')  # down arrow
                if [ $_HIGHLIGHTED_CHOICE -lt $_NUMBER_OF_CHOICES ]; then ((_HIGHLIGHTED_CHOICE++)); fi; _choose_refresh;;

            '')  # whitespace character
            
                # if last entry '> ...' was selected stop
                if [ $_HIGHLIGHTED_CHOICE -eq $_NUMBER_OF_CHOICES ]; then
                    unset CHOSEN;
                    for i in "${_CHOICES_ORDER[@]}"; do
                        if [ -v "CHOSEN_KEYS[$i]" ]; then
                            CHOSEN+=( "$i" )
                        fi
                    done
                    _chosen_keys_to_values
                    _chosen_to_newlines_output
                    
                    break
                fi
                
                unset CHOSEN; CHOSEN=${_CHOICES_ORDER[(($_HIGHLIGHTED_CHOICE - 1))]}
                _chosen_handle_multiple_valuekeys
                 
                for i in "${CHOSEN[@]}"; do
                    if [ -v "CHOSEN_KEYS[$i]" ]; then
                        unset CHOSEN_KEYS["$i"]
                    else
                        CHOSEN_KEYS["$i"]="chosen"
                    fi
                done
                
                # update the last entry to show selection
                local _DISPLAY_CHOSEN=">"
                for i in "${_CHOICES_ORDER[@]}"; do
                    if [ -v "CHOSEN_KEYS[$i]" ]; then
                        _DISPLAY_CHOSEN+=" $i"
                    fi
                done
                
                _CHOICES_ORDER[$((_NUMBER_OF_CHOICES - 1))]=$_DISPLAY_CHOSEN
                _choose_refresh
        esac
    done

}

