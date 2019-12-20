#!/bin/bash
#
# Directions for omnisharp
# Download omnisharp-mono.tar.gz
# Copy contents to .doom.d/omnisharp-mono
# put this script next to OmniSharp.exe

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
mono $DIR/OmniSharp.exe "$@"
