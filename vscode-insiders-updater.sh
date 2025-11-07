#!/bin/bash

# Script that build or updates Visual Studio Code - Insiders on Slackware Linux
#
# Copyright 2025 Branisalav Anovic
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

set -e

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root" >&2
    exit 1
fi

cd "$(dirname "$0")" ; CWD=$(pwd)

# Force reinstall flag
REINSTALL=0
for flag in "$@"; do
    [ "$flag" = "--reinstall" ] && REINSTALL=1
done

CHECK_URL="https://code.visualstudio.com/sha/download?build=insider&os=linux-x64"

# Update or install latest Visual Studio Code - Insiders build.
INSTALLED_VERSION=$(ls -v /var/log/packages/vscode-insiders-* 2>/dev/null | cut -d- -f3 | grep '^.[0-9]\+$' | sort -r | head -1)
AVAILABLE_VERSION=$(wget --spider --server-response "$CHECK_URL" 2>&1 | grep -i Content-Disposition | sed -En 's/^.*code-insider-x64-([0-9]+)\.tar\.gz.*$/\1/p')
if [ -z "$AVAILABLE_VERSION" ]; then
    echo "Error: Failed to fetch available version" >&2
    exit 1
fi

if [[ "$AVAILABLE_VERSION" != "$INSTALLED_VERSION" || $REINSTALL -eq 1 ]]; then
    echo "Visual Studio Code Insiders. Installing version ${AVAILABLE_VERSION} ..."

    if ! VISUAL_STUDIO_CODE_VERSION=${AVAILABLE_VERSION} ${CWD}/SlackBuild/vscode-insiders.SlackBuild; then
        echo "Error: Build failed" >&2
        exit 1
    fi

    PACKAGE=$(ls -r /tmp/vscode-insiders-$AVAILABLE_VERSION-*.t[gxbl]z | head -1)
    /sbin/upgradepkg --install-new --reinstall "$PACKAGE"
    rm -f "$PACKAGE"
else
    echo "Visual Studio Code - Insiders is up to date (installed: ${INSTALLED_VERSION})."
fi

