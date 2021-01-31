function print_args() {
        ### DEBUGGING.
        ### Print out all arguments parsed.

        local is_first=true
        printf "_kvargs: "
        for k in ${!_kvargs[@]}; do
                if [[ $is_first == false ]]; then
                        printf " "
                else
                        is_first=false
                fi
                printf "${k}=${_kvargs[$k]}"
        done
        printf "\n"

        printf "_optargs: "${_optargs[@]}"\n"
}
