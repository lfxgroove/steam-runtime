#!/bin/bash
#
# This script runs a shell with the environment set up for the Steam runtime 
# development environment.

# The top level of the cross-compiler tree
TOP=$(cd "${0%/*}" && echo "${PWD}")

exit_usage()
{
    echo "Usage: $0 [--arch=<arch>] [command] [arguments...]" >&2
    exit 1
}

HOST_ARCH=$(dpkg --print-architecture)
export HOST_ARCH

while [ "$1" ]; do
    case "$1" in
    --arch=*)
        TARGET_ARCH=$(expr "$1" : '[^=]*=\(.*\)')
        ;;
    -h|--help)
        exit_usage
        ;;
    -*)
        echo "Unknown command line parameter: $1" >&2
        exit_usage
        ;;
    *)
        break
        ;;
    esac

    shift
done
if [ -z "${TARGET_ARCH}" ]; then
    TARGET_ARCH="${HOST_ARCH}"
fi
export TARGET_ARCH

case "${TARGET_ARCH}" in
i386|amd64)
    ;;
*)
    echo "Unknown target architecture: ${TARGET_ARCH}"
    exit 1
    ;;
esac

# The top level of the Steam runtime tree
if [ -z "${STEAM_RUNTIME_ROOT}" ]; then
    if [ -d "${TOP}/runtime/${TARGET_ARCH}" ]; then
        STEAM_RUNTIME_ROOT="${TOP}/runtime/${TARGET_ARCH}"
    elif [ -d "${TOP}/../runtime/${TARGET_ARCH}" ]; then
        STEAM_RUNTIME_ROOT="${TOP}/../runtime/${TARGET_ARCH}"
    fi
fi
if [ ! -d "${STEAM_RUNTIME_ROOT}" ]; then
    echo "Couldn't find runtime directory ${STEAM_RUNTIME_ROOT}" >&2
    exit 2
fi
export STEAM_RUNTIME_ROOT

# Set up environment variables for this build
export PATH="${TOP}/bin:$PATH"

# Run the shell!
if [ "$*" = "" ]; then
    "${SHELL}" -i
else
    "$@"
fi

# vi: ts=4 sw=4 expandtab
