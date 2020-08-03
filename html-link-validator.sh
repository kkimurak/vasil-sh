#!/bin/sh

# @brief validate internal link in html that generated by asciidoctor
# @param $1 path for html you want to validate
# @return :
#   0 : every link seems to be works fine4
#   1 : too many argments
#   2 : file does not exist
#   3 : file format is invalid (not html)
#   4 or larger : returning value - validation_return_offset is the number of invalid links.
# @author kkimurak

validation_return_offset=3

VALIDATOR_ECHO=":"

if [ "${VALIDATOR_DEBUG}" = "true" ]; then
    VALIDATOR_ECHO="echo"
fi

VALIDATOR_EXEC_ATTRIBUTE=":"

if [ ! "${VALIDATOR_USE_AS_FUNCTION}" = "true" ];then
    VALIDATOR_EXEC_ATTRIBUTE=""
fi

validate_internal_link_in_html() {
    if [ ! $# -eq 1 ]; then
        ${VALIDATOR_ECHO} "too many (or less) argments: $# argments detected"
        ${VALIDATOR_ECHO} "usage: validate_internal_link_in_html target_file.html"
        return 1
    fi
    if [ ! -e "$1" ]; then
        ${VALIDATOR_ECHO} "$1 does not exist"
        return 2
    fi
    if [ ! "$(echo $1 | sed 's/^.*\.\([^\.]*\)$/\1/')" = "html" ]; then
        ${VALIDATOR_ECHO} "$1 is not html file"
        return 3
    fi

    IFS_org=${IFS}
    IFS="$(printf "#\n")"
    # start checking
    link_list="$(sed -e "s:\(.*\)<a href=:\1\n<a href=:g" $1 | grep "<a href=\"#" | sed 's:.*href="\#\(.*\)">.*:\1\#:g' | sort | uniq | tr -d "\n")"
    id_list="$(grep "<.* id=.*>" $1 | sed "s:\(<.*id=\"\)\(.*\)\">.*:\2:g" | sort)"
    error_counter=0;
    for link in ${link_list}; do
        if ! echo "${id_list}" | grep -q "${link}" ; then
            ${VALIDATOR_ECHO} "link \"${link}\" is invalid"
            error_counter=$((error_counter+1));
        fi
    done
    IFS=${IFS_org}
    ${VALIDATOR_ECHO} "${error_counter} invalid link found"
    # add offset
    if [ ! ${error_counter} -eq 0 ]; then
        error_counter=$((error_counter+validation_return_offset))
    fi

    return ${error_counter}
}

${VALIDATOR_EXEC_ATTRIBUTE} validate_internal_link_in_html "$@"