#!/bin/sh

# This script operates on a specific file
[ -f log/mkman-awscli.log ] || {
    echo >&2 'File not found: log/mkman-awscli.log'
    exit 1
}

# Define a `tac` function if the command is not found
which tac >/dev/null 2>&1 || tac() {
    cat ${*:+"$*"} | # Read from /dev/stdin or "$*"
    nl -ba         | # Number all lines
    sort -nr       | # Sort in reverse numerical order
    cut -f2-         # Remove the line numbers
}

# Make two files:
# - `mkman-awscli.err`: manpage creation errors with accompanying manpage names
# - `failed.txt`: just names of manpages that experienced errors during creation
tac log/mkman-awscli.log | awk '
/^[a-z]/ && keep {
    print cmd[++i] = $0
    keep = 0
}
!/^[a-z]/ {
    keep = 1
}
keep {
    print
}
END {
    printf "" > "log/failed.txt"
    while (i)
        print cmd[i--] >> "log/failed.txt"
}' | tac >log/mkman-awscli.err

# Assuming that manpages were generated in ./man, the following command line
# will determine if any manpages failed to generate (I have chosen 40 lines as
# the minimum number to exist in a manpage for it to be considered a success).
printf >&2 'The following manpages may have failed to generate:\n\n'
wc -l `sed 's#.*#man/&.a#' log/failed.txt` 2>&1 | sed '$d' | awk '$1 < 40'
