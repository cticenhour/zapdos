#* This file is part of Zapdos, an open-source
#* application for the simulation of plasmas
#* https://github.com/shannon-lab/zapdos
#*
#* Zapdos is powered by the MOOSE Framework
#* https://www.mooseframework.org
#*
#* Licensed under LGPL 2.1, please see LICENSE for details
#* https://www.gnu.org/licenses/lgpl-2.1.html

FROM ubuntu:20.04

WORKDIR /opt

# Add user dev
RUN useradd -s /bin/bash dev

ENV DEBIAN_FRONTEND=noninteractive

# Install base packages using apt-get as root
RUN apt-get update -y  && \
    apt-get upgrade -y && \
    apt-get install -y \
        build-essential \
        gfortran \
        tcl \
        git \
        m4 \
        freeglut3 \
        doxygen \
        libblas-dev \
        liblapack-dev \
        libx11-dev \
        libnuma-dev \
        libcurl4-gnutls-dev \
        zlib1g-dev \
        libhwloc-dev \
        python3 \
        python3-dev \
        python3-pip \
        curl \
        bison \
        flex \
        libboost-all-dev \
        vim \
        libgtest-dev \
        sudo \
        update-motd \
        rsync \
        cmake

# Clear package caches
RUN rm -rf /var/lib/apt/lists/*

# Set Python 3 as the default interpreter
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10

# Install python dependencies using pip3
RUN pip3 --no-cache-dir install \
        python-consul \
        python-nomad \
        beautifulsoup4 \
        jinja2 \
        livereload \
        lxml \
        matplotlib \
        mock \
        numpy \
        pandas \
        pybtex \
        pylatexenc \
        pyyaml \
        scikit-image

ENV MOOSE_JOBS=4

# Install MPICH 4.0.2 to system path
RUN curl -L -O https://www.mpich.org/static/downloads/4.0.2/mpich-4.0.2.tar.gz ; \
tar -xf mpich-4.0.2.tar.gz ; \
cd mpich-4.0.2 && mkdir gcc-build && cd gcc-build ; \
# Configure build env
../configure --prefix=/usr/local \
--enable-shared \
--enable-sharedlibs=gcc \
--enable-fast=O2 \
--enable-debuginfo \
--enable-totalview \
--with-device=ch3 \
CC=gcc \
CXX=g++ \
FC=gfortran \
F77=gfortran \
F90='' \
CFLAGS='' \
CXXFLAGS='' \
FFLAGS='' \
FCFLAGS='' \
F90FLAGS='' \
F77FLAGS='' ; \
# Build and install
make -j ${MOOSE_JOBS} ; \
make install ; \
# Cleanup
cd ../../ ; rm -rf mpich-4.0.2 ; \
# Ensure mpich was installed by checking for binary
if [ ! -f $(which mpicc) ]; then exit 1; fi

# Set influential environment variables
ENV CC=mpicc CXX=mpicxx

# Create projects location in user home directory
WORKDIR /home/dev
RUN mkdir projects
WORKDIR /home/dev/projects

# Clone Zapdos and update submodules
RUN git clone -b master https://github.com/shannon-lab/zapdos.git
WORKDIR /home/dev/projects/zapdos
RUN git submodule update --init

#ENV MOOSEDEV_REV=$(grep -oE "(\d+\.\d+\.\d+)" moose/conda/moose-dev/meta.yaml)

# Build PETSc and libMesh using MOOSE scripts
WORKDIR /home/dev/projects/zapdos/moose
RUN ./scripts/update_and_rebuild_petsc.sh --download-cmake
RUN ./scripts/update_and_rebuild_libmesh.sh
RUN ./scripts/update_and_rebuild_wasp.sh

# Make Zapdos
WORKDIR /home/dev/projects/zapdos
RUN make -j 2
RUN ./run_tests -j ${MOOSE_JOBS}

# Make dev the owner of everything within its home directory to avoid permissions issues
RUN chown -R dev:dev /home/dev

# Switch to dev user
USER dev

WORKDIR /home/dev
