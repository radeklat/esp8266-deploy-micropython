#!/usr/bin/env bash

SRC_ROOT='src'

ROOT_FOLDER="$( cd "$( dirname "$0" )" && pwd )"
PORTFILE="${ROOT_FOLDER}/.portdiscovery"
LASTUPDATED="${ROOT_FOLDER}/.lastupdated"
NEWER_CONDITION="-cnewer ${LASTUPDATED}"
CURRENT_OS="$(uname -s)"
AMPY_CMD='sudo ampy'
PORT_BASE='/dev/ttyUSB'
PORT_NUM_START=0

if [[ "${CURRENT_OS}" =~ (CYGWIN|MINGW).* ]]; then
    AMPY_CMD='ampy'
    PORT_BASE='COM'
    PORT_NUM_START=1
elif [ $EUID != 0 ]; then
    echo 'This script requires sudo to access serial ports.'
    exit 1
fi

detect_port() {
    echo "Discovering connected serial devices:"
    for i in $(cat "${PORTFILE}" 2>/dev/null) $(seq ${PORT_NUM_START} 10); do
        PORT="${PORT_BASE}${i}"
        echo -en "\t${PORT}: "
        ${AMPY_CMD} -p ${PORT} ls >/dev/null 2>&1

        if [[ $? -eq 0 ]]; then
            echo "found"
            echo -n "${i}" >"${PORTFILE}"
            return 0
        else
            echo "not found"
        fi
    done

    echo "No devices detected."
    exit 1
}

ampy_with_command_log() {
    echo -e "\t$@"
    ${AMPY_CMD} -p ${PORT} $@
}

rmall() {
    echo "Removing all files and folders:"
    for node in $(ampy -p ${PORT} ls); do
        cmd='rm'
        ${AMPY_CMD} -p ${PORT} rm "${node}" >/dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            cmd='rmdir'
            ${AMPY_CMD} -p ${PORT} rmdir "${node}" >/dev/null 2>&1
        fi
        echo -e "\t${cmd} ${node}"
    done
}

# $1 = additional time based filter condition for find
push_all() {
    local cnt=0
    local time_condition=$1

    echo "Pushing files:"

    for dirname in $(find . ! -path . -type d ${time_condition}); do
        ampy_with_command_log put "${dirname}"
        cnt=$(expr ${cnt} + 1)
    done

    for filename in $(find . -type f ${time_condition}); do
        ampy_with_command_log put "${filename}"
        cnt=$(expr ${cnt} + 1)
    done

    [[ ${cnt} -eq 0 ]] && echo 'No files were changed.'
}

while [[ "$#" > 0 ]]; do
    case $1 in
        -h|--help) show_help=true;;
        -u|--update) option_update=true;;
        *) test_exit 1 "Unknown option '$1'. Run program with -h or --help for help.";;
    esac
    shift
done

if [[ -n ${show_help+x} ]]; then
    echo -e "ESP8266 Deploy MicroPython utility script.\n"
    echo -e "Run as:\n  $0 [options]\n\nPossible options are:"
    echo -e "  -h, --help: Displays this help.\n"
    echo -e "  -u, --update: Do not remove anything from device and push only changed files and folders."
    exit 255
fi

detect_port

cd "${SRC_ROOT}"

if [[ ${option_update} != true ]]; then
    rmall
    NEWER_CONDITION=''
fi

if [[ ! -f "${LASTUPDATED}" ]]; then
    NEWER_CONDITION=''
fi

push_all "${NEWER_CONDITION}"

touch "${LASTUPDATED}"