#!/bin/sh

# Import config variables and check for required values
[ -f config.sh ] || {
    cat >&2 <<EOF
Missing file: config.sh
Have you copied example-config.sh to config.sh?
EOF
    exit 1
}
. ./config.sh
: "${section?}" "${nameprefix?}" "${outdir?}" "${logdir?}"
[ $? -eq 0 ] || {
    echo >&2 'Required config variable(s) unset'
    exit 1
}

# Create output directories
outdir=man logdir=log
mkdir -p "$outdir" "$logdir"

# Clear runtime data files
>"$logdir"/descriptions.txt

# Write `aws help` output in troff format (requires patch to AWS CLI)
export OUTPUT=troff

# Function to extract a list of available topics, services, or commands
list() {
    case $# in
       0) cat      # no arguments => man page is on STDIN
    ;; *) cat "$*" # 1+ arguments => man page file was provided
    esac | awk '
    # Exit once we have passed through the "AVAILABLE" section
    x && /^\.SH/ { exit }

    # Find the "AVAILABLE" section
    /^\.SH AVAILABLE/ { x = 1 }

    # Names come on their own line after ".IP \(bu 2"
    x && /^\.IP \\\(bu 2/ {
        getline

        # Remove "\" and ":" from names
        gsub(/[\\:]/, "")

        # Ignore available "help", as it is redundant
        if ($0 != "help") print
    }'
}

# Function to extract a one-sentence description from a man page
describe() {
    case $# in
       0) cat      # no arguments => man page is on STDIN
    ;; *) cat "$*" # 1+ arguments => man page file was provided
    esac | awk '
    # Find the "DESCRIPTION" section
    /^\.SH DESCRIPTION/ {

        # Skip lines beginning with "." or "\"
        do {
            getline
            if ($1 == ".SH") {
                print "ERROR: Empty \"DESCRIPTION\" section" >"/dev/stderr"
                exit 1
            }
        } while (/^[.\\]/)

        # Print the first sentence and exit
        split($0, sentences, /(\. )|(\.$)/)
        print sentences[1]
        exit
    }'
}

# Function to wrap different in-place sed implementations
if sed --version 2>/dev/null | grep GNU >/dev/null
then sed_is_gnu=true
else unset sed_is_gnu
fi
ised() {
    if [ "$sed_is_gnu" ]
    then sed -i "$@"
    else sed -i '' "$@"
    fi
}

# Function to add a short description to the "NAME" section of a man page.
# This information is used by makewhatis(8) to create the whatis database,
# which is used apropos(1) to search for man pages. Also replaces the title
# and name with the fully-qualified name (e.g. "aws-s3-ls" vs. "ls").
modify_manpage() {
    local manpage=$1 name=$2 NAME=`echo "$2" | tr a-z A-Z | sed 's/-/\\-/g'`

    # Remove or transform troublesome strings in the description
    # Note that a heredoc is used to avoid interpolated control characters
    local desc=`sed 's/\\\\f.//g' <<EOF | tr -d '\\\\' | sed 's#/#\\\\/#g'
$3
EOF
`
    # Perform the man page modification
    ised -e "s/^\\.TH .*/.TH \"$NAME\" \"$section\" \"\" \"\"/" \
         -e "/^\\.SH NAME/{n;s/.*/$name \\\\- $desc/;}" \
         "$manpage"

    # FIXME: Combine this and the above ised command
    # Clean up the "NAME" section for whatis indexing
    local tmpfile=`mktemp`
    local prefix
    case $name in
    aws)
        prefix= ;;
    aws-*)
        prefix=aws- ;;
    *)
        prefix=$name- ;;
    esac
    awk '
    /^\.SH NAME/ {
        # Print the "NAME" section
        print
        getline
        print

        # Set a skip-bit
        x = 1
        next
    } {
        # Skip until we have reached the next section or paragraph (some man
        # pages only have one section, so we must also look for paragraphs)
        if (x && !/^\.(SH|sp)/) {
            next
        } else {
            print
            x = 0
        }
    }' "$manpage" | awk '
    x && /^\.SH/ { x = 0 }
    /^\.SH AVAILABLE/ { x = 1 }
    x && /^\.IP \\\(bu 2/ {
        print
        getline

        # Remove backslashes and colons
        gsub(/[\\:]/, "")

        # Prepend the name of the current manpage
        sub(/^/, prefix)

        # Append the manual section in parenthesis to "AVAILABLE" section items
        sub(/$/, "("section")")

        print
        next
    } { print }' prefix=$prefix section=$section >"$tmpfile"
    mv "$tmpfile" "$manpage"
    rm -f "$tmpfile"

    # Debugging information
    printf '%s\t%s\n' "$name" "$desc" >>"$logdir"/descriptions.txt
}

# Function to generate top-level man pages for AWS CLI
mkman_awscli() {
    local name manpage desc sub

    # Generate man pages for aws and aws-topics
    for sub in '' 'topics'
    do
        # Determine and output the name of the man page 
        name=aws${sub:+"-$sub"}
        echo >&2 $name

        # Generate the man page if it does not already exist
        manpage=$outdir/$name'.'$section
        [ -f "$manpage" ] || aws help $sub >"$manpage"

        # Pull a one-sentence description from the man page
        desc=`describe <"$manpage"`

        # Modify the title and short description of the man page
        modify_manpage "$manpage" "$name" "$desc"
    done
}

# Function to generate man pages for special topics of the AWS CLI
mkman_topics() {
    local name manpage desc topic

    # Get available topics
    aws help topics | list | while read topic desc
    do
        # Determine and output the name of the man page 
        name=aws-$topic
        echo >&2 "$name"

        # Generate the man page if it does not already exist
        manpage=$outdir/$name'.'$section
        [ -f "$manpage" ] || aws help $topic >"$manpage"

        # Modify the title and short description of the man page
        modify_manpage "$manpage" "$name" "$desc"
    done
}

# Function to recursively generate man pages for AWS CLI commands. Depth-first
# traversal is used. Example invocations:
#
#   mkman_commands ''             # top-level commands (i.e. services) on down
#   mkman_commands dynamodb       # dynamodb subcommands on down
#   mkman_commands dynamodb wait  # dynamodb-wait subcommands on down
# 
mkman_commands() {
    local name manpage desc subcommand command="$*"

    # Get available subcommands
    aws $command help | list | while read subcommand
    do
        # Determine and output the name of the man page 
        name=$nameprefix`echo $command $subcommand | tr ' ' -`
        echo >&2 "$name"

        # Generate the man page if it does not already exist
        manpage=$outdir/$name'.'$section
        [ -f "$manpage" ] || aws $command $subcommand help >"$manpage"

        # Pull a one-sentence description from the man page
        desc=`describe <"$manpage"`

        # Modify the title and short description of the man page
        modify_manpage "$manpage" "$name" "$desc"

        # Recursive call
        mkman_commands $command $subcommand
    done
}

# Generate all man pages
mkman_awscli
mkman_topics
mkman_commands ''
