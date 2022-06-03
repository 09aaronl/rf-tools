#!/bin/bash
#
# This script requires INSTALL_PATH (typically /opt/rf-tools),
# RFTOOLS_PATH (typically /opt/rf-tools/source), and
# MINICONDA_PATH (typically /opt/miniconda) to be set.
#
# A miniconda install must exist at $CONDA_DEFAULT_ENV
# and $CONDA_DEFAULT_ENV/bin must be in the PATH
#
# Otherwise, this only requires the existence of the following files:
#	requirements-git.txt
#	requirements-py3.txt
#	requirements-compile.txt

set -e -o pipefail

echo "PATH:              ${PATH}"
echo "INSTALL_PATH:      ${INSTALL_PATH}"
echo "CONDA_PREFIX:      ${CONDA_PREFIX}"
echo "RFTOOLS_PATH:      ${RFTOOLS_PATH}"
echo "MINICONDA_PATH:    ${MINICONDA_PATH}"
echo "DLIB_PATH:         ${DLIB_PATH}"
echo "RNAFRAMEWORK_PATH: ${RNAFRAMEWORK_PATH}"
echo "DRACO_PATH:        ${DRACO_PATH}"
echo "CONDA_DEFAULT_ENV: ${CONDA_DEFAULT_ENV}"

CONDA_CHANNEL_STRING="--override-channels -c conda-forge -c bioconda"

# setup/install rf-tools directory tree and conda dependencies
sync

# clone git repos
while read repo; do
	IFS='=' read -r -a array <<< "$repo"
	git clone "${array[2]}" /opt/"${array[0]}"
done < "$RFTOOLS_PATH/requirements-git.txt"

# install conda dependencies for building dlib, draco from source
conda install -y \
	-q $CONDA_CHANNEL_STRING \
	--file "$RFTOOLS_PATH/requirements-build.txt" \
	-p "${CONDA_PREFIX}"

# cmake dlib
source ~/.bashrc
mkdir $DLIB_PATH/build; cd $DLIB_PATH/build
cmake ..
cmake --build . --config Release
make install
ldconfig

# cmake draco
mkdir $DRACO_PATH/build; cd $DRACO_PATH/build
sed -i 's=tbb/tbb_stddef.h=oneapi/tbb/version.h=g' $DRACO_PATH/cmake/Modules/FindTBB.cmake
cmake .. -DCMAKE_BUILD_TYPE=Release -DLINK_TIME_OPTIMIZATIONS=ON -DNATIVE_BUILD=ON -DARMA_NO_WRAPPER=ON
make
cd ../extra/simulate_mm
cargo build --release

# uninstall conda dependencies for building
# install conda dependencies for RNAframework
conda remove -y $(cat $RFTOOLS_PATH/requirements-build-only.txt)
conda install -y \
	-q $CONDA_CHANNEL_STRING \
	--file "$RFTOOLS_PATH/requirements-py3.txt" \
	-p "${CONDA_PREFIX}"

# clean up
conda clean -y --all