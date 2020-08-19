#!/bin/bash

### Usage:
### ./run.sh --main hello

readonly _DIR="$( cd -P "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd )"


### Imports.
### --------

. ${_DIR}/utils.sh # utility functions.


### Dependencies.
### -------------


### Write your code.

function hello() {

        printf "Hello World!\n"
}


### Arguments.
### ----------

declare -a _positional=()

## public
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


### Main.
### -----

function main() {
        ### Main.

        parse_args "$@"
        assert_var_set "_main" "$_main"
        $_main "${_positional[@]}"
        return "$?"
}


### Entry.
### ------

main "$@"
