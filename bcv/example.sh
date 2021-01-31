#!/bin/bash

### Usage:
### ./example.sh --main hello --msg "2021"

readonly BCV_DIR="./BCV" # the directory of BCV.


### Imports.
### --------

. ${BCV_DIR}/Main.sh # Must import Main.sh of BCV


### Fields.
### -------

# f_x=""
f_msg="World" # a key-value pair
f_quiet=0 # an option


### Functions.
### ----------

function hello() {
        ### If option `quiet` is not set, then print the message.

        if ! -B- $f_quiet; then # -B- is a syntactic sugar to cast any
                                # value to a bool.
                printf "Hello, ${f_msg}!\n"
        fi
}


### Entry.
### ------

main "$@" # Must include this
