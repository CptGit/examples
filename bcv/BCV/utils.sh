#!/bin/bash

### Log.
### ----

function log() {
        ### Log messages with "BCV:" as a prefix.
        ### @level log level, one of "info, debug, error or warning"
        ### @msg text of log

        local level="$1"; shift
        local msg="$1"; shift

        log0 "$level" "$msg" "BCV:"
}

function log0() {
        ### Log messages.
        ### @level log level, one of "info, debug, error or warning"
        ### @msg text of log
        ### @prefix prefix added to the message

        local level="$1"; shift
        local msg="$1"; shift
        local prefix="$1"; shift

        case "$level" in
        'i'|'info')
                printf "${prefix}INFO: ${msg}\n"
                ;;
        'd'|'debug')
                printf "${prefix}DEBUG: ${msg}\n"
                ;;
        'e'|'error')
                printf "${prefix}ERROR: ${msg}\n"
                ## TODO: is it good to exit here?
                exit
                ;;
        'w'|'warning')
                printf "${prefix}WARNING: ${msg}\n"
                ;;
        *)
                printf "${prefix}UNCATEGORIZED: ${msg}\n"
                ;;
        esac
}


### Assert.
### -------

function assert_var_set() {
        ### Assert a variable is set.
        ### @name variable name

        local name="$1"; shift

        test -z "${!name}" && log e "Variable \"${name}\" is NOT set!"
}

function assert_file_exists() {
        ### Assert a file exists.
        ### @file the path of the given file

        local file="$1"; shift
        test -f "$file" || log e "$file does NOT exist!"
}


### Time.
### -----

function curr_millis() {
        ### Return the current time in GMT in milliseconds.

        echo "$(($(date -u +%s%N)/1000000))"
}

function millis_to_human_readable_format() {
        ### Return day:hour:min:second:millisecond format (no leading
        ### zeros) for the given number of milliseconds.

        local millis="$1"; shift

        # Convert
        local milliseconds=$((${millis}%1000))
        local seconds=$((${millis}/1000%60))
        local minutes=$((${millis}/1000/60%60))
        local hours=$((${millis}/1000/60/60%24))
        local days=$((${millis}/1000/60/60/24))

        # Remove leading zeros
        local output=""
        if [[ ${days} -eq 0 ]]; then
                if [[ ${hours} -eq 0 ]]; then
                        if [[ ${minutes} -eq 0 ]]; then
                                if [[ ${seconds} -eq 0 ]]; then
                                        output="${milliseconds}ms"
                                else
                                        output="${seconds}s:${milliseconds}ms"
                                fi
                        else
                                output="${minutes}m:${seconds}s:${milliseconds}ms"
                        fi
                else
                        output="${hours}h:${minutes}m:${seconds}s:${milliseconds}ms"
                fi
        else
                output="${days}d:${hours}h:${minutes}m:${seconds}s:${milliseconds}ms"
        fi

        echo "${output}"
}
