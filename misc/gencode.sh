#!/bin/bash

_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

## Args declaration and default initialization
declare -a POSITIONAL=()
HAS_GUARD="FALSE"
CONTENT=""
EXTENSION="hpp"
DEFAULT=""

function parse_args() {
        ## Parse args
        while [[ $# -gt 0 ]]; do
                key="${1}"

                case "$key" in
                "-e"|"--extension")
                        EXTENSION="${2}"
                        shift # past argument
                        shift # past value
                        ;;
                "-c"|"--content")
                        CONTENT="${2}"
                        shift # past argument
                        shift # past value
                        ;;
                "-g"|"--guard")
                        HAS_GUARD="TRUE"
                        shift # past argument
                        ;;
                "--default")
                        DEFAULT=YES
                        shift # past argument
                        ;;
                *)    # unknown option
                        POSITIONAL+=("${1}") # save it in an array for later
                        shift # past argument
                        ;;
                esac
        done
        set -- "${POSITIONAL[@]}" # restore positional parameters
}

function gen() {
        ## Generate a sequence of template files in current working
        ## directory
        declare -a filenames=("${POSITIONAL[@]}")
        local extension="${EXTENSION}"

        ## Check passed filenames
        if [[ -z "${filenames}" ]]; then
                log e "Please give file name(s)."
                return 1;
        fi

        for filename in ${filenames[@]}; do
                local output_file="${filename}.${extension}"

                ## Clean file
                if [[ -f ${output_file} ]]; then
                        rm -fr ${output_file}
                fi

                case "${extension}" in
                "h"|"hpp")
                        gen_hpp "${filename}"
                        ;;
                "cpp")
                        gen_cpp "${filename}"
                        ;;
                *)
                        log e "Extension ${extension} is not supported yet."
                        return 1;
                        ;;
                esac

                if [[ -a "${output_file}" ]]; then
                        log h "SUCCESS! ${output_file} generated in cwd."
                else
                        log h "No file generated."
                fi
        done
}

function gen_hpp() {
        ## Generate a single hpp file
        local filename="${1}"; shift
        local content="${CONTENT}"
        local extension="${EXTENSION}"

        ## Generate the beginning part of include guard
        local macro="$(echo ${filename}_$(date +%Y%m%d%H%M%S)_${extension} | tr '[:lower:]' '[:upper:]')"
        echo "#ifndef ${macro}" >> "${output_file}"
        echo "#define ${macro}" >> "${output_file}"

        ## Print the content to the output file
        if [[ ! -z "${content}" ]]; then
                echo >> "${output_file}"
                cat "${content}" >> "${output_file}"
        fi

        ## Generate the ending part of include guard
        echo >> "${output_file}"
        echo "#endif // ${macro}" >> "${output_file}"
}

function gen_cpp() {
        ## Generate a single cpp file
        local filename="${1}"; shift
        local content="${CONTENT}"

        ## Generate the statement including its corresponding header
        ## file.
        local header="${filename}.hpp"
        echo "#include \"${header}\"" >> "${output_file}"

        ## Print the content to the output file
        if [[ ! -z "${content}" ]]; then
                echo >> "${output_file}"
                cat "${content}" >> "${output_file}"
        fi
}

function log() {
        ## Print log
        local type="${1}"; shift
        local msg="${1}"; shift

        case "${type}" in
        "d"|"debug")
                printf "[DEBUG] ${msg}\n"
                ;;
        "e"|"error")
                printf "[ERROR] ${msg}\n"
                ;;
        "w"|"warning")
                printf "[WARNING] ${msg}\n"
                ;;
        "h"|"hint")
                printf "[HINT] ${msg}\n"
                ;;
        *)
                printf "[BLING] ${msg}\n"
                ;;
        esac
}

function main() {
        parse_args $@
        gen
        local ret_val=$?
        if [[ "${ret_val}" -ne "0" ]]; then
                log e "Generation halted."
        fi
}

main $@
