FROM quay.io/broadinstitute/viral-baseimage:0.1.15

# Largely borrowed from https://github.com/broadinstitute/viral-ngs/blob/master/Dockerfile

LABEL maintainer "aelin@princeton.edu"

# to build:
#   docker build . 
#
# to run:
#   docker run --rm <image_ID> "<command>.py subcommand"
#
# to run interactively:
#   docker run --rm -it <image_ID>

ENV \
	INSTALL_PATH="/opt/rf-tools" \
	RFTOOLS_PATH="/opt/rf-tools/source" \
	MINICONDA_PATH="/opt/miniconda" \
	CONDA_DEFAULT_ENV="rf-tools-env" \
	DLIB_PATH="/opt/dlib" \
	RNAFRAMEWORK_PATH="/opt/rnaframework" \
	DRACO_PATH="/opt/draco" \
	CONDA_DEFAULT_ENV=rf-tools-env

ENV \
	PATH="$RNAFRAMEWORK_PATH:$DRACO_PATH/build/src:$DRACO_PATH/extra/simulate_mm/target/release:$MINICONDA_PATH/bin:$RFTOOLS_PATH/scripts:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
	CONDA_PREFIX="$MINICONDA_PATH/envs/$CONDA_DEFAULT_ENV" \
	JAVA_HOME="$MINICONDA_PATH"

# Prepare rf-tools user and installation directory
# Set it up so that this slow & heavy build layer is cached
# unless the requirements* files or the install scripts actually change
WORKDIR $INSTALL_PATH
RUN conda update -n base -c defaults conda
RUN conda create -n $CONDA_DEFAULT_ENV
RUN echo "source activate $CONDA_DEFAULT_ENV" > ~/.bashrc
RUN hash -r
COPY ./ $RFTOOLS_PATH/
RUN $RFTOOLS_PATH/docker/install-rf-tools.sh

RUN /bin/bash -c "set -e; echo -n 'version: '; which draco"

CMD ["/bin/bash"]