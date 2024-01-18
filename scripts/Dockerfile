#* This file is part of Zapdos, an open-source
#* application for the simulation of plasmas
#* https://github.com/shannon-lab/zapdos
#*
#* Zapdos is powered by the MOOSE Framework
#* https://www.mooseframework.org
#*
#* Licensed under LGPL 2.1, please see LICENSE for details
#* https://www.gnu.org/licenses/lgpl-2.1.html

FROM mooseharbor.hpc.inl.gov/moose-docker/moose:latest

WORKDIR /opt

RUN GIT_SSL_NO_VERIFY=true git clone --depth 1 -b master https://github.com/shannon-lab/zapdos.git

WORKDIR /opt/zapdos

RUN GIT_SSL_NO_VERIFY=true git submodule update --depth 1 --init moose crane squirrel

ENV LIBMESH_DIR=/opt/libmesh
ENV PETSC_DIR=/opt/petsc
ENV WASP_DIR=/opt/wasp
ENV MOOSE_JOBS=4

RUN make -j ${MOOSE_JOBS}

RUN ./run_tests --all-tests -j ${MOOSE_JOBS}
