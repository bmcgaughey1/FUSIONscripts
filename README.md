
<!-- README.md is generated from README.Rmd. Please edit that file -->

# FUSIONscripts

<!-- badges: start -->

<!-- badges: end -->

FUSIONscripts holds the processing scripts for AreaProcessor that are
distributed with FUSION. This repository was created to put the scripts
(DOS batch files) under version control and to facilitate sharing.

There is another repository (FUSIONscriptsADV) that has more advanced
scripts for use with AreaProcessor workflows. However, the advanced
scripts are not for the meek. They produce more metrics and require a
bit more work to configure and use.

One major caution with both sets of scripts is that the cell size for
metrics cannot be changed by simply changing the cell size in
AreaProcessor. You also have to edit the setup scripts (script run
before tile processing begins) to reflect the desired cell size. Failure
to change the setup scripts is one of the most common issues that cause
AreaProcessor workflow runs to fail. If you simply change the cell size
in AreaProcessor without editing the setup scripts, everything will
appear to run until near the end of the processing when merging of
outputs will fail. There are comments in the setup scripts included in
both sets describing the necessary changes.
