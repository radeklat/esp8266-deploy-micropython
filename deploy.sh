#!/usr/bin/env bash

SRC_ROOT='src'
PORTFILE='.portdiscovery'

detect_port() {
    for i in $(cat "${PORTFILE}" 2>/dev/null) $(seq 1 10); do
        PORT="COM${i}"
        ampy -p ${PORT} ls >/dev/null 2>&1

        if [[ $? -eq 0 ]]; then
            echo "Detected device on port ${PORT}."
            echo -n "${i}" >"${PORTFILE}"
            return 0
        fi
    done

    echo "No devices detected."
    exit 1
}

ampycmd() {
    echo -e "  $@"
    ampy -p ${PORT} $@
}

rmall() {
    echo "Removing all files and folders:"
    for node in $(ampy -p ${PORT} ls); do
        ampy -p ${PORT} rm "${node}" >/dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            ampy -p ${PORT} rmdir "${node}" >/dev/null 2>&1
        fi
        echo "${node}"
    done
}

while [[ "$#" > 0 ]]; do
    case $1 in
        -h|--help) show_help=true;;
        -nr|--no-remove) no_remove=true;;
        *) test_exit 1 "Unknown option '$1'. Run program with -h or --help for help.";;
    esac
    shift
done

if [[ -n ${show_help+x} ]]; then
    echo -e "ESP8266 Deploy MicroPython utility script.\n"
    echo -e "Run as:\n  $0 [options]\n\nPossible options are:"
    echo -e "  -h, --help: Displays this help.\n"
    echo -e "  -nr, --no-remove: File on device won't be removed before pushing new files."
    exit 255
fi

detect_port

cd "${SRC_ROOT}"

if [[ ${no_remove} != true ]]; then
    rmall
fi

echo "Copying files and directories:"

for dirname in $(find . ! -path . -type d); do
    ampycmd put "${dirname}"
done

for filename in $(find . -type f); do
    ampycmd put "${filename}"
done

ampycmd reset