#!/bin/sh

# Set up temporary file
tmpfile=`mktemp`
trap "rm -f '$tmpfile'" 0 1 2 3 15

# Clean up the "NAME" section for whatis indexing
for manpage in *.a
do
    echo "$manpage"
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
}' "$manpage" >"$tmpfile"
    cp "$tmpfile" "$manpage"
done
