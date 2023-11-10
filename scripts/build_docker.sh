#!/bin/bash

#* This file is part of Zapdos, an open-source
#* application for the simulation of plasmas
#* https://github.com/shannon-lab/zapdos
#*
#* Zapdos is powered by the MOOSE Framework
#* https://www.mooseframework.org
#*
#* Licensed under LGPL 2.1, please see LICENSE for details
#* https://www.gnu.org/licenses/lgpl-2.1.html


# This script builds a Zapdos docker container based on the current master branch
# for upload to Docker Hub

# Set optional push parameter (defaults to NO / 0 if not set by the user)
if [ -z "$PUSH" ]; then
  PUSH=0
fi

# Set location of Zapdos source location based on script location
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export ZAPDOS_DIR="$( cd $SCRIPT_DIR/.. && pwd)"
echo "ZAPDOS_DIR=$ZAPDOS_DIR"

# Enter Zapdos source location, checkout master branch, and save latest git commit hash
cd $ZAPDOS_DIR
git checkout master
ZAPDOS_MASTER_HASH=$(git rev-parse master)

# Build docker container and tag it with master git hash (Docker Desktop must be installed and active)
cd $ZAPDOS_DIR/scripts
docker build -t shannonlab/zapdos:"$ZAPDOS_MASTER_HASH" . || exit $?

# Retag newly built container to make a second one with the tag "latest"
docker tag shannonlab/zapdos:"$ZAPDOS_MASTER_HASH" shannonlab/zapdos:latest

# Push both containers to Docker Hub, if enabled. If not, display a notice to the screen with more info
if [[ $PUSH == 1 ]]; then
  docker push shannonlab/zapdos:$ZAPDOS_MASTER_HASH
  docker push shannonlab/zapdos:latest
else
  echo ""
  echo "INFO: Push to Docker Hub disabled. If desired in the future, run this script"
  echo "      with PUSH=1 in your environment. To push now, run the following two"
  echo "      commands:"
  echo ""
  echo "      docker push shannonlab/zapdos:$ZAPDOS_MASTER_HASH"
  echo "      docker push shannonlab/zapdos:latest"
fi
