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

detect_port

cd "${SRC_ROOT}"

rmall

echo "Copying files and directories:"

for dirname in $(find . ! -path . -type d); do
    ampycmd put "${dirname}"
done

for filename in $(find . -type f); do
    ampycmd put "${filename}"
done

ampycmd reset