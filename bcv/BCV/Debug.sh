#!/bin/bash

function print_args() {
        ### DEBUGGING.
        ### Print out all arguments parsed.

        local is_first=1
        printf "_r_kvargs: "
        for k in ${!_r_kvargs[@]}; do
                if -B- $is_first; then
                        printf " "
                else
                        is_first=0
                fi
                printf "${k}=${_r_kvargs[$k]}"
        done
        printf "\n"

        printf "_r_optargs: "${_r_optargs[@]}"\n"
}
