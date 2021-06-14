#!/bin/sh

# Import config variables and check for required values
[ -f config.sh ] || {
    cat >&2 <<EOF
Missing file: config.sh
*** Have you copied example-config.sh to config.sh?
EOF
    exit 1
}
. config.sh
: "${outdir?}" "${installdir?}" "${section?}"
[ $? -eq 0 ] || {
    echo >&2 'Required config variable(s) unset'
    exit 1
}

# Install man pages
case `echo "$outdir"/*` in
"$outdir/*")
    cat >&2 <<EOF
No man pages to be installed in specified outdir: $outdir
*** Is outdir set correctly in config.sh?  If so, then either re-run
*** mkman-awscli.sh or checkout the upstream branch to repopulate outdir.
EOF
    exit 1 ;;
*)  
    mkdir -p "$installdir"
    install -m 644 "$outdir"/* "$installdir"
esac

# Index the man pages
os=`uname -s`
case $os in
Darwin)
    sudo /usr/libexec/makewhatis "$installdir" ;;
Linux|*)
    # TODO: Add support for different Linux distros
    cat >&2 <<EOF
Unsupported operating system: $os
*** Try consulting your man pages for makewhatis(8) or mandb(8)
EOF
    exit 1
esac

# Give some post-installation advice
mansect=1:1p:8:2:3:3p:4:5:6:7:9:0p:tcl:n:l:p:o
manpath=/usr/share/man:/usr/local/share/man
expr "X$section" \
   : "X\\(`echo "$mansect" | sed 's/:/\\\|/g'`\\)" >/dev/null \
   || mansect=$mansect:$section         # nonstandard section
expr "X${installdir%/*}" \
   : "X\\(`echo "$manpath" | sed 's/:/\\\|/g'`\\)" >/dev/null \
   || manpath=$manpath:${installdir%/*} # nonstandard installdir
cat >&2 <<EOF
Man pages have been installed!

*** IMPORTANT POST-INSTALL NOTES ***

- In order to find and use the man pages, you must ensure that the specified
  section and installation directory are known by man-related commands.

- If you specified a non-standard section (which is the default specified in
  example-config.sh) or installation directory, the easiest way to accomplish
  the above is by setting the MANSECT and MANPATH environment variables.

- For example, MANSECT and MANPATH can be set in your bash config as follows:

  $ echo "export MANSECT='$mansect'" >> ~/.bash_profile
  $ echo "export MANPATH='$manpath'" >> ~/.bash_profile
EOF
