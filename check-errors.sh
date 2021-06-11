#!/bin/sh

# Import config variables and check for required values
[ -f config.sh ] || {
    cat >&2 <<EOF
Missing file: config.sh
Have you copied example-config.sh to config.sh?
EOF
    exit 1
}
. config.sh
: "${outdir?}" "${logdir?}"
[ $? -eq 0 ] || {
    echo >&2 'Required config variable(s) unset'
    exit 1
}

# This script operates on a specific file
[ -f "$logdir/mkman-awscli.log" ] || {
    echo >&2 "File not found: $logdir/mkman-awscli.log"
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
# - `$logdir/mkman-awscli.err`: generation errors with accompanying man page names
# - `$logdir/error-pages.txt`:  just names of man pages that experienced generation errors
tac "$logdir/mkman-awscli.log" | awk '
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
    printf "" > (logdir "/error-pages.txt")
    while (i)
        print cmd[i--] >> (logdir "/error-pages.txt")
}' logdir="$logdir" | tac >"$logdir/mkman-awscli.err"

# The following command line will heuristically determine if any man pages
# failed to generate based on the number of lines in the file. 
printf >&2 'The following man pages may have failed to generate:\n\n'
wc -l `sed "s#.*#$outdir/&.a#" "$logdir/error-pages.txt"` 2>&1 \
    | sed '$d' | awk '$1 < 40' # at least 40 lines required
