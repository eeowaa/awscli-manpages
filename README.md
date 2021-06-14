# AWS CLI Man Pages

This repository contains man pages for each AWS CLI command and provides the
means of regenerating them.

The man pages contained in this repo were generated against a local installation
of the AWS CLI with the following version information:

```
$ aws --version
aws-cli/2.2.8 Python/3.9.5 Darwin/20.5.0 source/x86_64 prompt/off
```

## Installing man pages

Most of the time, you will not want to regenerate man pages, as it takes a long
time (and can be prone to errors). Simply install the contents of the
[`man/`](man) directory into your system like you would any other collection of
man pages. Be sure to update the `whatis` database to be able to search for the
man pages via `apropos` and friends.

A script has been provided for such purposes: [`install.sh`](install.sh).

## Generating man pages

The only prerequisite not found on a standard \*nix system is the AWS CLI
itself. Install it with your package manager and then perform the following
steps:

1. Copy [`example-config.sh`](example-config.sh) to `config.sh` and edit
   configuration variables in the file.
2. Run `./patch-awscli.sh` to patch the AWS CLI with the ability to produce
   help text in `troff` format.
3. Run `./mkman-awscli.sh` to create man pages in `man/`.
4. Run `./check-errors.sh` to check for errors in generation (see the
   _`warnings.txt` and `errors.txt`_ section of [`ref/README.md`](ref/README.md)
   for more information).


-------------------------------------------------------------------------------
**NOTE**: This documentation is incomplete (see [`BUGS.md`](BUGS.md)).
