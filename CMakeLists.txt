cmake_minimum_required(VERSION 3.18)
# CMake version compatibility

#[==============================================================================[
#                         Basic project definition                              #
#]==============================================================================]

project(Access3Share VERSION "0.3.1"
                  HOMEPAGE_URL https://github.com/access-nri/access-om3
                  DESCRIPTION "Global coupled ocean - sea ice - wave model"
                  LANGUAGES C Fortran)

#[==============================================================================[
#                                   Options                                     #
#]==============================================================================]

# Configurations to build
list(APPEND KnownConfigurations MOM6 CICE6 WW3 MOM6-CICE6 CICE6-WW3 MOM6-WW3 MOM6-CICE6-WW3)


# Build options
option(OM3_BIN_INSTALL       "Install ACCESS-OM3 executables" ON)
option(ACCESS3_LIB_INSTALL   "Install ACCESS-OM3 libraries" OFF)
option(ACCESS3_OPENMP        "Enable OpenMP threading" OFF)
# option(ACCESS3_MOM_SYMMETRIC "Use symmetric memory" OFF) #move to MOM6

if(ACCESS3_LIB_INSTALL)
  set(OM3_BIN_INSTALL OFF)
endif()

message(STATUS "Build options")
message(STATUS "  - OM3_BIN_INSTALL   ${OM3_BIN_INSTALL}")
message(STATUS "  - ACCESS3_LIB_INSTALL   ${ACCESS3_LIB_INSTALL}")
message(STATUS "  - ACCESS3_OPENMP        ${ACCESS3_OPENMP}")
# message(STATUS "  - ACCESS3_MOM_SYMMETRIC ${ACCESS3_MOM_SYMMETRIC}")

if (OM3_BIN_INSTALL)

  option(OM3_ENABLE_MOM6           "Build MOM6 configuration" OFF)
  option(OM3_ENABLE_CICE6          "Build CICE6 configuration" OFF)
  option(OM3_ENABLE_WW3            "Build WW3 configuration" OFF)
  option(OM3_ENABLE_MOM6-WW3       "Build MOM6-WW3 configuration" OFF)
  option(OM3_ENABLE_MOM6-CICE6     "Build MOM6-CICE6 configuration" ON)
  option(OM3_ENABLE_CICE6-WW3      "Build CICE6-WW3 configuration" ON)
  option(OM3_ENABLE_MOM6-CICE6-WW3 "Build MOM6-CICE6-WW3 configuration" ON)

  message(STATUS "Configurations")
  message(STATUS "  - MOM6              ${OM3_ENABLE_MOM6}")
  message(STATUS "  - CICE6             ${OM3_ENABLE_CICE6}")
  message(STATUS "  - WW3               ${OM3_ENABLE_WW3}")
  message(STATUS "  - MOM6-WW3          ${OM3_ENABLE_MOM6-WW3}")
  message(STATUS "  - MOM6-CICE6        ${OM3_ENABLE_MOM6-CICE6}")
  message(STATUS "  - CICE6-WW3         ${OM3_ENABLE_CICE6-WW3}")
  message(STATUS "  - MOM6-CICE6-WW3    ${OM3_ENABLE_MOM6-CICE6-WW3}")

endif()

#[==============================================================================[
#                           Project configuration                               #
#]==============================================================================]

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(GNUInstallDirs)
if(ACCESS3_LIB_INSTALL)
  include(CMakePackageConfigHelpers)
endif()

# Include some custom cmake modules
include(FortranLib)
include(AddPatchedSource)

## Configure project variables
if (OM3_BIN_INSTALL)
  # Do not build components that are not going to be used
  if(OM3_ENABLE_MOM6 OR OM3_ENABLE_MOM6-CICE6 OR OM3_ENABLE_MOM6-WW3 OR OM3_ENABLE_MOM6-CICE6-WW3)
    set(OM3_ENABLE_MOM6 ON)
  else()
    set(OM3_ENABLE_MOM6 OFF)
  endif()
  if(OM3_ENABLE_CICE6 OR OM3_ENABLE_MOM6-CICE6 OR OM3_ENABLE_CICE6-WW3 OR OM3_ENABLE_MOM6-CICE6-WW3)
    set(OM3_ENABLE_CICE6 ON)
  else()
    set(OM3_ENABLE_CICE6 OFF)
  endif()
  if(OM3_ENABLE_WW3 OR OM3_ENABLE_MOM6-WW3 OR OM3_ENABLE_CICE6-WW3 OR OM3_ENABLE_MOM6-CICE6-WW3)
    set(OM3_ENABLE_WW3 ON)
  else()
    set(OM3_ENABLE_WW3 OFF)
  endif()

endif()

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
find_package(ESMF 8.3.0 MODULE REQUIRED)
if(ACCESS3_OPENMP)
  find_package(OpenMP REQUIRED)
endif()

if (ACCESS3_LIB_INSTALL)
  find_package(FoX 4.1.2 REQUIRED)
  find_package(PIO 2.5.3 REQUIRED COMPONENTS C Fortran)
  find_package(NetCDF 4.7.3 REQUIRED Fortran)
endif()

if (OM3_BIN_INSTALL)
  find_package(Access3Share REQUIRED cdeps cmeps nuopc_cap_share share timing) #should this list components which are required?
  if(OM3_ENABLE_CICE6)
    # find_package(Access3Share REQUIRED cdeps-docn)
    find_package(AccessCiceCmeps REQUIRED)
  endif()
endif()
#[==============================================================================[
#                             Main definitions                                  #
#]==============================================================================]

if(ACCESS3_LIB_INSTALL)
  # Some code shared by several components
  add_subdirectory(share)

  # Data component (CDEPS)
  add_subdirectory(CDEPS)

  # Mediator component (CMEPS)
  add_subdirectory(CMEPS)
endif()

if (OM3_BIN_INSTALL)
  # Add executable for each enabled configuration
  foreach(CONF IN LISTS KnownConfigurations)
    if(NOT OM3_ENABLE_${CONF})
      continue()
    endif()

    set(ComponentsTargets "")
    if(OM3_${CONF} MATCHES MOM6)
      list(APPEND ComponentsTargets AccessMom6::mom6-cmeps)
    else()
      list(APPEND ComponentsTargets Access3Share::cdeps-docn)
    endif()
    if(OM3_${CONF} MATCHES CICE6)
      list(APPEND ComponentsTargets AccessCiceCmeps::cice-cmeps)
    else()
      list(APPEND ComponentsTargets Access3Share::cdeps-dice)
    endif()
    if(OM3_${CONF} MATCHES WW3)
      list(APPEND ComponentsTargets AccessWw3::ww3-cmeps)
    else()
      list(APPEND ComponentsTargets Access3Share::cdeps-dwav)
    endif()

      # We use the CESM driver from CMEPS
    add_fortran_library(OM3_cesm_driver_${CONF} mod/OM3_cesm_driver_${CONF} STATIC
      CMEPS/CMEPS/cesm/driver/esm.F90
      CMEPS/CMEPS/cesm/driver/ensemble_driver.F90
      CMEPS/CMEPS/cesm/driver/esm_time_mod.F90
    )
    target_link_libraries(OM3_cesm_driver_${CONF}
      PUBLIC esmf
      PRIVATE ${ComponentsTargets} Access3Share::cdeps-drof Access3Share::cdeps-datm Access3Share::cmeps Access3Share::nuopc_cap_share Access3Share::share Access3Share::timing
    )
    target_compile_definitions(OM3_cesm_driver_${CONF} PRIVATE MED_PRESENT
                                                                ATM_PRESENT
                                                                ICE_PRESENT
                                                                OCN_PRESENT
                                                                WAV_PRESENT
                                                                ROF_PRESENT
                                                                $<$<CONFIG:Debug>:DEBUG>
    )

    add_executable(OM3_${CONF} CMEPS/CMEPS/cesm/driver/esmApp.F90)
    target_link_libraries(OM3_${CONF} PRIVATE OM3_cesm_driver_${CONF} Access3Share::share esmf)

    set_target_properties(OM3_${CONF} PROPERTIES
      LINKER_LANGUAGE Fortran
      OUTPUT_NAME access-om3-${CONF}
    )
  endforeach()
endif()

#[==============================================================================[
#                             Install or Export                                 #
#]==============================================================================]

## Installs

# Note that the installation of some components is done in the corresponding subdirectory

# OM3 executables
if(OM3_BIN_INSTALL)
  foreach(CONF IN LISTS KnownConfigurations)
    if(NOT OM3_ENABLE_${CONF})
      continue()
    endif()

    install(TARGETS OM3_${CONF}
      RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
  endforeach()
endif()

# # Libraries
if(ACCESS3_LIB_INSTALL)
  configure_package_config_file(
    cmake/Access3ShareConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/Access3ShareConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Access3Share
  )
  install(FILES ${CMAKE_SOURCE_DIR}/cmake/FindFoX.cmake ${CMAKE_CURRENT_BINARY_DIR}/Access3ShareConfig.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Access3Share
    COMPONENT Access3Share
  )
endif()
