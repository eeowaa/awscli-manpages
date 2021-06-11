#!/bin/sh
die() {
    echo >&2 "$*"
    exit 1
}

# Make sure that we have our patch file in the working directory
patch=troff-help.patch
[ -f "$patch" ] || die "file does not exist: $patch"

# Find the `aws` executable
awscli=`which aws`
[ -f "$awscli" ] || die "file does not exist: $awscli"

# Find the parent directory of the canonical path to `aws`
bindir=`readlink -f "$awscli" | sed 's,/[^/]*$,,'`
[ -d "$bindir" ] || die "directory does not exist: $bindir"

# Find the canonical path to the `help.py` script used by `aws`
helppy=`readlink -f \`echo "$bindir"/../lib/*/site-packages/awscli/help.py\``
[ -f "$helppy" ] || die "file does not exist: $helppy"

# Patch the `help.py` script with the ability to create troff output
patch -b "$helppy" < "$patch"
