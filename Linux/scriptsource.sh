#!/usr/bin/env bash
# This code is originally from http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in

# It is a useful one-liner which will give you the full directory name of the script no matter where it is being called from

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Or, to get the dereferenced path (all directory symlinks resolved), do this:

DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# These will work as long as the last component of the path used to find the script is not a symlink (directory links are OK).
# If you want to also resolve any links to the script itself, you need a multi-line solution:

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
