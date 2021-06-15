## Bugs

1. [`README.md`](README.md) is missing some instructions.

2. Man page generation is extremely slow (on the order of hours on my local
   machine). Optimization is possible through caching and parallelization.

   - It could also be argued that patching the documentation upstream to more
     easily generate man pages (including short descriptions) would drastically
     reduce both complexity for the user and compute time in generating
     man pages.


## Missing features

1. Incremental documentation generation via `Makefile`.

2. [`install.sh`](install.sh) is missing features for operating systems other
   than macOS.

3. Automatic retries on partial or total man page generation failure.  This
   currently requires some shell-fu.


## Upstream issues

1. The documentation for some services do not include a description. As of
   June 10th, 2021, the following services do not include descriptions:

   - `aws-identitystore`
   - `aws-kinesis-video-archived-media`
   - `aws-kinesis-video-media`
   - `aws-kinesisvideo`
   - `aws-lexv2-models`
   - `aws-lexv2-runtime`
   - `aws-mturk`
   - `aws-nimble`
   - `aws-personalize-runtime`
   - `aws-resourcegroupstaggingapi`
   - `aws-s3api`
   - `aws-servicecatalog`
   - `aws-ssm-contacts`
   - `aws-sso-admin`
   - `aws-timestream-query`

2. There are lots of warnings during generation of the man pages (see the
   _`warnings.txt` and `errors.txt`_ section of [`ref/README.md`](ref/README.md))
   which are inextricable from the documentation source.

3. There are no links between man pages using `.Xr` macros.
