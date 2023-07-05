#!/usr/bin/env bash
#############################
set -e
#############################

if [ -z "${1}" ] || [ -z "${2}" ] || [ -z "${3}" ]; then
    printf "Expected: [ username ] [ user_id ] [ group_id ]";
    exit 1
fi

username="${1}"
uid="${2}"
gid="${3}"

groupadd -g ${gid} -o ${username}
useradd -m -u ${uid} -g ${gid} -o -s /bin/bash ${username}
