Running `tools/filter-log-errors.sh` (from the parent directory) will parse
`log/mkman-awscli.log` for errors and extract information into separate files:

- `log/mkman-awscli.err`: generation errors with accompanying manpage names
- `log/failed.txt`: just names of manpages that experienced generation errors

However, errors don't necessarily indicate failures. I have manually determined
regular expression patterns in `mkman-awscli.err` that indicate warnings vs.
real "errors" (i.e. failures) and have specified them in two separate files:

- `warnings.txt`: expressions that can safely be ignored
- `errors.txt`: expressions that indicate at least partial failure

Each expression in those two files uses extended POSIX regular expressions,
with a couple extensions: literal `\n` are allowed, and `\` at the end of a
line indicates a continuation of the expression on the following line. Each
expression is separated by a blank line.
