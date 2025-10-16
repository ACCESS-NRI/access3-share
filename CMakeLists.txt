# Copyright ACCESS-NRI and contributors. See the top-level COPYRIGHT file for details.
# SPDX-License-Identifier: Apache-2.0

# This CMakeLists file has an option to control what to build:
# ACCESS3_LIB_INSTALL:
# If ON, then build libraries for the shared components (CMEPS/CDEPS/Share)
# If OFF, then build ACCESS-OM3 using CMEPS code and linked to model components (built elsewhere).
# Build components are set through the KnownConfigurations CMAKE variable 
# This can be extended to included CM3 by linking against the UM libraries built with nuopc/cmeps driver.

cmake_minimum_required(VERSION 3.18)
# CMake version compatibility

#[==============================================================================[
#                         Basic project definition                              #
#]==============================================================================]

project(Access3Share 
        HOMEPAGE_URL https://github.com/access-nri/access3-share
        DESCRIPTION "Dependencies for global climate models"
        LANGUAGES C Fortran)

# https://github.com/ACCESS-NRI/spack-config/blob/c744fb21824d7d1b2c1613a19ed544f2b9f61603/common/gadi/linux/compilers.yaml#L419C1-L431C21
# - > intel-compiler-llvm/2025.2.0
# ifx --print-prog-name=llvm-ar
# /apps/intel-tools/.packages/2025.2.0.575/compiler/2025.2/bin/compiler/llvm-ar
# https://github.com/ACCESS-NRI/ACCESS-OM3/pull/148#:~:text=to%20the%20linker%20%3F-,Looks%20like%20the%20line%20is%20calling%20the%20archiver.%20Instead%20of%20ar%2C%20you%20need%20to%20invoke%20the%20llvm%2Dar%20%2D%20the%20full%20path%20to%20which%20you%20can%20get%20by%20using%20ifx%20%2D%2Dprint%2Dprog%2Dname%3Dllvm%2Dar%20(or%20mpifort%20instead%20of%20ifx),-Member
# Below force invoking llvm-ar to have a look
# set(CMAKE_AR "/apps/intel-tools/.packages/2025.2.0.575/compiler/2025.2/bin/compiler/llvm-ar" CACHE FILEPATH "" FORCE)
# Did you try set(CMAKE_AR "llvm-ar" ...?
set(CMAKE_AR "llvm-ar" CACHE FILEPATH "" FORCE)

#[==============================================================================[
#                                   Options                                     #
#]==============================================================================]

# Build options
option(ACCESS3_LIB_INSTALL       "Install ACCESS3 libraries"  OFF)

message(STATUS "Build options")
message(STATUS "  - ACCESS3_LIB_INSTALL   ${ACCESS3_LIB_INSTALL}")


#[==============================================================================[
#                           Project configuration                               #
#]==============================================================================]

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(GNUInstallDirs)

# Include some custom cmake modules
include(FortranLib)
include(AddPatchedSource)

# Common compiler flags and definitions
if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fbacktrace -fconvert=big-endian -ffree-line-length-none -ffixed-line-length-none")
  if(${CMAKE_Fortran_COMPILER_VERSION} VERSION_GREATER_EQUAL 10)
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fallow-argument-mismatch")
  endif()
  set(CMAKE_Fortran_FLAGS_RELEASE "-O")
  set(CMAKE_Fortran_FLAGS_DEBUG "-g -Wall -Og -ffpe-trap=zero,overflow -fcheck=bounds")
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -qno-opt-dynamic-align  -convert big_endian -assume byterecl -ftz -traceback -assume realloc_lhs -fp-model precise")
  set(CMAKE_Fortran_FLAGS_RELEASE "-O2 -debug minimal")
  set(CMAKE_Fortran_FLAGS_DEBUG "-O0 -g -check uninit -check bounds -check pointers -fpe0 -check noarg_temp_created")
else()
  message(WARNING "Fortran compiler with ID ${CMAKE_Fortran_COMPILER_ID} will be used with CMake default options")
endif()

if(CMAKE_C_COMPILER_ID MATCHES "GNU")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=gnu99")
  set(CMAKE_C_FLAGS_RELEASE "-O")
  set(CMAKE_C_FLAGS_DEBUG "-g -Wall -Og -fbacktrace -ffpe-trap=invalid,zero,overflow -fcheck=bounds")
elseif(CMAKE_C_COMPILER_ID MATCHES "Intel")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -traceback -qno-opt-dynamic-align -fp-model precise -std=gnu99")
  set(CMAKE_C_FLAGS_RELEASE "-O2 -debug minimal")
  set(CMAKE_C_FLAGS_DEBUG "-O0 -g")
else()
  message(WARNING "C compiler with ID ${CMAKE_C_COMPILER_ID} will be used with CMake default options")
endif()

add_compile_definitions(
  CESMCOUPLED
)

## Fortran modules path; currently this is simply set to be the include dir
set(CMAKE_INSTALL_MODULEDIR ${CMAKE_INSTALL_INCLUDEDIR}
  CACHE STRING
  "Fortran module installation path (Not a cmake native variable)"
)

#[==============================================================================[
#                              External packages                                #
#]==============================================================================]

# Find dependencies
find_package(MPI REQUIRED COMPONENTS Fortran)
find_package(ESMF 8.3.0 MODULE REQUIRED)

#[==============================================================================[
#                             Build and Install                                 #
#]==============================================================================]

## Use seperate files for building libraries vs final exectuable

if(ACCESS3_LIB_INSTALL)
  include(Access3LibInstall)
else()
  include(Access3BinInstall)
endif()