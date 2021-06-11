The `descriptions.txt` file in this directory was manually created by
copy/pasting descriptions from the AWS public website.

Although most of these descriptions are nicer than the values automatically
obtained from the "DESCRIPTION" field of the offline documentation, there are a
few issues with using manually-obtained descriptions:

1. It's manual work.
   - Enough said.
1. Descriptions on the AWS public website can change.
   - There is no mechanism for detecting such changes.
   - Manual work is bad enough; unplanned manual work is unacceptable, which
     would be required to keep the manpages up-to-date.
2. These descriptions are only available at the service level.
   - Most manpages are for commands and subcommands, which do not have
     carefully-crafted short descriptions defined anywhere. In these cases, the
     automated approach is the only sane approach.

Due to these issues, I have decided to use the automated approach across the
board for obtaining manpage descriptions. However, I still think it's worth
keeping the old `descriptions.txt` file around as a reference point in case I
ever decided to revisit this in the future.
