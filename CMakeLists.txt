# This CMakeLists file has two options:
# ACCESS3_LIB_INSTALL, to build libraries for the shared components (CMEPS/CDEPS/Share)
# ACCESS3_BIN_INSTALL, to build ACCESS-OM3 using CMEPS code and linked to model components (built elsewhere). 
# This can be extended to included CM3 by linking against the UM libraries built with nuopc/cmeps driver.

cmake_minimum_required(VERSION 3.18)
# CMake version compatibility

#[==============================================================================[
#                         Basic project definition                              #
#]==============================================================================]

project(Access3Share VERSION "0.3.1"
                  HOMEPAGE_URL https://github.com/access-nri/access3-share
                  DESCRIPTION "Global coupled ocean - sea ice - wave model"
                  LANGUAGES C Fortran)

#[==============================================================================[
#                                   Options                                     #
#]==============================================================================]

# Build options
option(ACCESS3_BIN_INSTALL       "Install ACCESS3 executables" ON)
option(ACCESS3_LIB_INSTALL       "Install ACCESS3 libraries"  OFF)
# option(OPENMP                "Enable OpenMP threading" OFF)
# option(ACCESS3_MOM_SYMMETRIC "Use symmetric memory" OFF) #move to MOM6

if(ACCESS3_LIB_INSTALL)
  set(ACCESS3_BIN_INSTALL OFF)
endif()

message(STATUS "Build options")
message(STATUS "  - ACCESS3_BIN_INSTALL   ${ACCESS3_BIN_INSTALL}")
message(STATUS "  - ACCESS3_LIB_INSTALL   ${ACCESS3_LIB_INSTALL}")
# message(STATUS "  - OPENMP        ${ACCESS3_OPENMP}")
# message(STATUS "  - ACCESS3_MOM_SYMMETRIC ${ACCESS3_MOM_SYMMETRIC}") #move to MOM6



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
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -qno-opt-dynamic-align  -convert big_endian -assume byterecl -ftz -traceback -assume realloc_lhs -fp-model source")
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
find_package(MPI REQUIRED)
# if(OPENMP)
#   find_package(OpenMP REQUIRED)
# endif()

find_package(ESMF 8.3.0 MODULE REQUIRED)

#[==============================================================================[
#                             Build and Install                                 #
#]==============================================================================]

## Use seperate files for building libraries vs final exectuable

# OM3 executables
if(ACCESS3_BIN_INSTALL)
  include(Access3BinInstall)
endif()

# Libraries
if(ACCESS3_LIB_INSTALL)
  include(Access3LibInstall)
endif()