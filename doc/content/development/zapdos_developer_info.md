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
`latest`. The script has the following parameter:

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
TODO: switch this out

Use 'docker scan' to run Snyk tests against images to find vulnerabilities and learn how to fix them

INFO: Push to Docker Hub disabled. If desired in the future, run this script
      with PUSH=1 in your environment or run the following two commands:

      docker push shannonlab/zapdos:2c4a214d4d55106ac6c8c9058e3b224a46ba416d
      docker push shannonlab/zapdos:latest
```
