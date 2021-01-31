#!/bin/bash

readonly BCV_ROOT_DIR=$( cd -P "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd )


### Imports.
### --------

. ${BCV_ROOT_DIR}/Utils.sh # utility functions.
. ${BCV_ROOT_DIR}/Debug.sh # debugging functions.


### Parse command line arguments.
### -----------------------------

declare -A _kvargs=()
declare -a _optargs=()
declare -a _positional=()

_main="" ## function as entry

function parse_args() {
        ### Parse arguments.

        while [[ "$#" -gt 0 ]]; do
                local arg="$1"

                case "$arg" in
                '-h'|'--help')
                        println "Usage: SCRIPT --main FUNCTION"
                        println
                        println "Example: "
                        println "  ./example.sh --main hello"
                        exit 0
                        ;;
                '--main')
                        _main="$2"
                        shift # past key
                        shift # past value
                        ;;
                '--'?*)
                        local key="${arg:2}"
                        if [[ "$2" == '--'?* ]]; then
                                ## This is actually an option.
                                _optargs+=("$key")
                                shift
                        else
                                ## This is really a key-value pair.
                                _kvargs["$key"]+="$2"
                                shift
                                shift
                        fi
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

        ## DEBUG
        # print_args

        ## Execute the function
        $_main "${_positional[@]}"
        return "$?"
}
