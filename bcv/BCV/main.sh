#!/bin/bash

readonly BCV_ROOT_DIR=$( cd -P "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd )


### Imports.
### --------

. ${BCV_ROOT_DIR}/utils.sh # utility functions.


### Inner fields.
### -------------

declare -a _positional=()
_main="" ## function as entry

function parse_args() {
        ### Parse arguments.

        while [[ "$#" -gt 0 ]]; do
                key="$1"

                case "$key" in
                '--main')
                        _main="$2"
                        shift # past key
                        shift # past value
                        ;;
                *) # unknown option
                        _positional+=("$1") # save it in an array for later
                        shift # past argument
                        ;;
                esac
        done
        set -- "${_positional[@]}"
}

function is_function() {
        ### Return true if the given name is a function defined in the
        ### script.
        local name="$1"

        if [[ "$( type -t "$name" )" = 'function' ]]; then
                return 0
        else
                return 1
        fi
}


### Main.
### -----

function main() {
        ### Main.

        parse_args "$@"

        ## Check if main is set
        if [[ -z ${_main} ]]; then
                log e "main function is NOT specified!"
        fi

        ## Check if main is a valid function
        if ! is_function "$_main"; then
                log e "function $_main is NOT defined!"
        fi

        ## Execute the function
        $_main "${_positional[@]}"
        return "$?"
}
