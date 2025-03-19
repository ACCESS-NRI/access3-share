# ACCESS3-Share

ACCESS3-Share repository contains the common tools for coupling the components of 3rd generation ACCESS earth system models. These are the framework for ACCESS-OM3 (an ocean and sea-ice model),  ACCESS-ESM3 (a global climate model) and other ACCESS models. This repository contains a CMake based build system for the [Community Mediator for Earth Prediction Systems](https://github.com/ESCOMP/CMEPS/), the [Community Data Models for Earth Prediction Systems](https://github.com/ESCOMP/CDEPS/) and the [Community Earth System Model shared code](https://github.com/ESCOMP/CESM_share). 

The contents of this repository are licensed under the _Apache 2.0_ license unless otherwise noted. For any submodules, please refer to the seperate repositories for license information. 

NCI-based users of ACCESS-OM3 typically won't need to mess with this package. There are pre-built executables available on NCI and some [configurations](https://github.com/accESS-NRI/access-om3-configs). 

This respository contains submodules, so you will need to clone it with the `--recursive` flag:
```
git clone --recursive https://github.com/COSIMA/access-om3.git
```

To update a previous clone of this repository to the latest version, you will need to do 
```
git pull
```
followed by
```
git submodule update --init --recursive
```
to update all the submodules.

# Further information (including building and running the model)

See the [ACCESS-OM3 configurations](https://github.com/accESS-NRI/access-om3-configs)
