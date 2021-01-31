#!/bin/bash

readonly BCV_ROOT_DIR=$( cd -P "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd )


### Imports.
### --------

. ${BCV_ROOT_DIR}/Util.sh # utility functions.
. ${BCV_ROOT_DIR}/Debug.sh # debugging functions.


### Parse command line arguments.
### -----------------------------

declare -A _r_kvargs=()
declare -a _r_optargs=()
declare -a _r_positional=()

_r_main="" ## function as entry

function parse_args() {
        ### Parse arguments.

        while [[ "$#" -gt 0 ]]; do
                local arg="$1"

                case "$arg" in
                '-h'|'--help')
                        println "Usage: SCRIPT --main FUNCTION --FIELD VALUE"
                        println
                        println "Example: "
                        println "  ./example.sh --main hello --msg 2021"
                        exit 0
                        ;;
                '--main')
                        _r_main="$2"
                        shift # past key
                        shift # past value
                        ;;
                '--'?*)
                        local key="${arg:2}"
                        if [[ "$2" == '--'?* || $2 == '' ]]; then
                                ## This is actually an option.
                                _r_optargs+=("$key")
                                shift
                        else
                                ## This is really a key-value pair.
                                _r_kvargs["$key"]+="$2"
                                shift
                                shift
                        fi
                        ;;
                *) # unknown option
                        _r_positional+=("$1") # save it in an array for later
                        shift # past argument
                        ;;
                esac
        done
        set -- "${_r_positional[@]}"
}

function set_fields() {
        ### Set corresponding fields based on arguments parsed.

        ## Set each key-value field.
        for k in ${!_r_kvargs[@]}; do
                local field_name="f_$k"
                if is_variable_set "${field_name}"; then
                        ## If the field is defined by users, we update
                        ## its value.
                        eval "${field_name}=\"${_r_kvargs[$k]}\""
                else
                        ## If the field is NOT defined, we throw an
                        ## error.
                        log e "Field ${k} is NOT defined!"
                fi
        done

        ## TODO: maybe we need to reconsider the logic of options. For
        ## now we require users to define an option field as 0.
        ## Set each value field.
        for opt in ${_r_optargs[@]}; do
                local field_name="f_$opt"
                if is_variable_set "${field_name}"; then
                        ## If the field is defined by users, we set it
                        ## to true.
                        eval "f_${opt}=1"
                else
                        ## If the field is NOT defined, we throw an
                        ## error.
                        log e "Field ${opt} is NOT defined!"
                fi
        done
}


### Main.
### -----

function main() {
        ### Main.

        parse_args "$@"

        ## Check if main is set
        if [[ -z ${_r_main} ]]; then
                log e "main function is NOT specified!"
        fi

        ## Check if main is a valid function
        if ! is_function_set "$_r_main"; then
                log e "function $_r_main is NOT defined!"
        fi

        ## DEBUG
        # print_args

        set_fields

        ## Execute the function
        $_r_main "${_r_positional[@]}"
        return "$?"
}
