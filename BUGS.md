## Bugs

1. The `README.md` is missing some instructions.

2. Manpage generation is extremely slow (on the order of hours on my local
   machine). Optimization is possible through caching and parallelization.

   - It could also be argued that patching the documentation upstream to more
     easily generate manpages (including short descriptions) would drastically
     reduce both complexity for the user and compute time in generating
     manpages.


## Missing features

1. A configuration file to specify output directory, installation directory,
   manpage section, etc.

2. Incremental documentation generation via `Makefile`.

3. A script for installing and indexing manpages once generated.

4. Automatic retries on partial or total manpage generation failure.  This
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

2. There are lots of warnings during generation of the manpages (see
   `tools/warnings.txt`), most of which are benign, but are inextricable
   from the documentation source.
