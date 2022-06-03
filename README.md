[![Docker Repository on Quay](https://quay.io/repository/aelin/rf-tools/status "Docker Repository on Quay")](https://quay.io/repository/aelin/rf-tools)

# rf-tools
This repo contains the Docker files needed to build the image `quay.io/aelin/rf-tools`. This image is based on the ubuntu
image `quay.io/broadinstitute/viral-baseimage:0.1.15` and contains tools for experimentally guided RNA structure prediction.

 - read processing: RNAframework
 - structure prediction: ViennaRNA, RNAstructure
 - ensemble deconvolution: DRACO

To build, run `docker build .` from within the directory containing the `Dockerfile`.