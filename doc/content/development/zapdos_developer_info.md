# Zapdos Developer Information

This page is meant for Zapdos developers and will change over time as development practices and
processes change - please refer back to this page regularly. If MOOSE user and developer information
is desired, please refer to the [moose_developer_info.md] page.

## Update and Build a New Docker Container

!style halign=left
The Zapdos docker container image should be updated whenever Zapdos source code or that of submodules
(CRANE, Squirrel, or MOOSE) are updated and those changes are merged into the master branch. To build
a new docker container, first fetch the most up-to-date version of the Zapdos master branch. Assuming
that Zapdos is stored in `~/projects/` and that your `upstream` remote is referencing
[shannon-lab/zapdos](https://github.com/shannon-lab/zapdos.git):

```bash
cd ~/projects/zapdos
git fetch upstream
git checkout master
git reset --hard upstream/master
```

Once your local master branch is up-to-date, the `build_socker.sh` script can be used to create two
new images, one tagged with the most recent git commit hash for the master branch and one tagged
`latest`. The script has the following optional parameter:

- `PUSH` - a boolean value that sets whether the built packages should be pushed to the `shannonlab/zapdos`
  Docker Hub repository when the build is completed (defaults to `0`)

Example usage of the script is outlined as follows. First, start the script from the Zapdos directory:

```bash
cd ~/projects/zapdos
scripts/build_docker.sh
```

In this case, the docker images will remain local and will not be pushed to Docker Hub (`PUSH=0`).
Example output for this command is shown below:

```bash
% scripts/build_docker.sh
ZAPDOS_DIR=/Users/user/projects/zapdos
Already on 'master'
[+] Building 1362.3s (15/15) FINISHED                                                                                                                               docker:desktop-linux
 => [internal] load .dockerignore                                                                                                                                                   0.0s
 => => transferring context: 2B                                                                                                                                                     0.0s
 => [internal] load build definition from Dockerfile                                                                                                                                0.0s
 => => transferring dockerfile: 1.19kB                                                                                                                                              0.0s
 => [internal] load metadata for docker.io/idaholab/moose-dev:latest                                                                                                                1.2s
 => [ 1/11] FROM docker.io/idaholab/moose-dev:latest@sha256:46d6eb808d0bb50ab156e06c40b1c51c83f24faac963604a0ff006a900da2dd2                                                        0.0s
 => => resolve docker.io/idaholab/moose-dev:latest@sha256:46d6eb808d0bb50ab156e06c40b1c51c83f24faac963604a0ff006a900da2dd2                                                          0.0s
 => => sha256:46d6eb808d0bb50ab156e06c40b1c51c83f24faac963604a0ff006a900da2dd2 532B / 532B                                                                                          0.0s
 => => sha256:f06c86b2ca91a39e5702f3878f541f426cb349a4b9ae04d3df449949f0c594ec 13.71kB / 13.71kB                                                                                    0.0s
 => [ 2/11] RUN useradd -s /bin/bash dev                                                                                                                                            0.6s
 => [ 3/11] WORKDIR /home/dev                                                                                                                                                       0.1s
 => [ 4/11] RUN git clone -b master https://github.com/shannon-lab/zapdos.git                                                                                                     120.2s
 => [ 5/11] WORKDIR /home/dev/zapdos                                                                                                                                                0.0s
 => [ 6/11] RUN git submodule update --init moose crane squirrel                                                                                                                   68.2s
 => [ 7/11] RUN source /opt/mpi/use-mpich ;     make -j 4                                                                                                                         837.4s
 => [ 8/11] RUN source /opt/mpi/use-mpich ;     ./run_tests --all-tests -j 4                                                                                                      297.3s
 => [ 9/11] WORKDIR /home/dev                                                                                                                                                       0.0s
 => [10/11] RUN cp /run_singularity2docker.sh /home/dev/run_singularity2docker.sh                                                                                                   0.2s
 => [11/11] RUN chown -R dev:dev /home/dev                                                                                                                                         30.3s
 => exporting to image                                                                                                                                                              6.9s
 => => exporting layers                                                                                                                                                             6.9s
 => => writing image sha256:cbf610db1138f0f7c3c07540d0ce4fded73b7c4d80a845f8ba7722eaebec3b07                                                                                        0.0s
 => => naming to docker.io/shannonlab/zapdos:b4d10e02a1f50432640144e8097e26ebe57a5c45                                                                                               0.0s

What's Next?
  View a summary of image vulnerabilities and recommendations → docker scout quickview

INFO: Push to Docker Hub disabled. If desired in the future, run this script
      with PUSH=1 in your environment. To push now, run the following two
      commands:

      docker push shannonlab/zapdos:b4d10e02a1f50432640144e8097e26ebe57a5c45
      docker push shannonlab/zapdos:latest
```
