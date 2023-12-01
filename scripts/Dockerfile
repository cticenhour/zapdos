#* This file is part of Zapdos, an open-source
#* application for the simulation of plasmas
#* https://github.com/shannon-lab/zapdos
#*
#* Zapdos is powered by the MOOSE Framework
#* https://www.mooseframework.org
#*
#* Licensed under LGPL 2.1, please see LICENSE for details
#* https://www.gnu.org/licenses/lgpl-2.1.html

FROM idaholab/moose-dev:latest

# Add dev user
RUN useradd -s /bin/bash dev
WORKDIR /home/dev

# Clone zapdos, download zapdos dependencies, make, and test zapdos as root user
RUN git clone -b master https://github.com/shannon-lab/zapdos.git

WORKDIR /home/dev/zapdos

RUN git submodule update --init moose crane squirrel

ENV LIBMESH_DIR=/opt/libmesh
ENV PETSC_DIR=/opt/petsc
ENV WASP_DIR=/opt/wasp
ENV MOOSE_JOBS=4

RUN source /opt/mpi/use-mpich ; \
    make -j ${MOOSE_JOBS}

RUN source /opt/mpi/use-mpich ; \
    ./run_tests --all-tests -j ${MOOSE_JOBS}

WORKDIR /home/dev

# Make sure init script from / that docker initialization needs is in dev home dir
RUN cp /run_singularity2docker.sh /home/dev/run_singularity2docker.sh

# Make sure dev user owns all of the home directory
RUN chown -R dev:dev /home/dev

# Switch to dev user
USER dev
