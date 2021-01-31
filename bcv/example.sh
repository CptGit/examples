#!/bin/bash

### Usage:
### ./example.sh --main hello

readonly _DIR="$( cd -P "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd )"


### Imports.
### --------

. BCV/main.sh # Must import main.sh of BCV


### Fields.
### -------

WELCOME_MSG="New construction options!"


### Functions.
### ----------

function hello() {

        printf "${WELCOME_MSG}\n"
}


### Entry.
### ------

main "$@" # Must include this
