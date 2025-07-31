# Copyright ACCESS-NRI and contributors. See the top-level COPYRIGHT file for details.
# SPDX-License-Identifier: Apache-2.0

## share library
add_fortran_library(share mod/share STATIC)
add_library(Access3::share ALIAS share)
target_include_directories(share PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/CESM_share/include>")
if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
  target_compile_definitions(share PRIVATE CPRGNU NAMING=_ADD_UNDERSCORE FORTRANUNDERSCORE)
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
  target_compile_definitions(share PRIVATE CPRINTEL NAMING=_ADD_UNDERSCORE FORTRANUNDERSCORE)
endif()
target_link_libraries(share
  PUBLIC ESMF::ESMF MPI::MPI_Fortran
  PRIVATE Access3::timing PIO::PIO_Fortran
)
target_sources(share PRIVATE
  # The following files are generated with a script acting on templates
  # We include pre-generated files that are committed to the repository
  src/shr_assert_mod.F90
  src/shr_frz_mod.F90
  src/shr_infnan_mod.F90
  src/dtypes.h

  # Modules shared among several components
  CESM_share/include/shr_assert.h
  CESM_share/src/shr_abort_mod.F90
  CESM_share/src/shr_cal_mod.F90
  CESM_share/src/shr_file_mod.F90
  CESM_share/src/shr_kind_mod.F90
  CESM_share/src/shr_log_mod.F90
  CESM_share/src/shr_mem_mod.F90
  CESM_share/src/shr_mpi_mod.F90
  CESM_share/src/shr_nl_mod.F90
  CESM_share/src/shr_orb_mod.F90
  CESM_share/src/shr_pio_mod.F90
  CESM_share/src/shr_precip_mod.F90
  CESM_share/src/shr_reprosum_mod.F90
  CESM_share/src/shr_reprosumx86.c
  CESM_share/src/shr_strconvert_mod.F90
  CESM_share/src/shr_string_mod.F90
  CESM_share/src/shr_sys_mod.F90
  CESM_share/src/shr_timer_mod.F90
  CESM_share/src/shr_wv_sat_mod.F90
  CESM_share/src/water_isotopes/water_isotopes.F90

  # The following file is a stub.
  stubs/mct_mod.F90
)
add_patched_source(share CESM_share/src/nuopc_shr_methods.F90)
add_patched_source(share CESM_share/src/shr_const_mod.F90)

if(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
  # CESM reduces the precision and increases speed for the following file
  set_source_files_properties(CESM_share/src/shr_wv_sat_mod.F90 PROPERTIES COMPILE_FLAGS "-fimf-precision=low -fp-model fast")
endif()

## GPTL timing library
add_fortran_library(ACCESS3_timing mod/timing STATIC)
add_library(Access3::timing ALIAS ACCESS3_timing)
target_compile_definitions(ACCESS3_timing PRIVATE NUOPC_INTERFACE HAVE_MPI)
if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
  target_compile_definitions(ACCESS3_timing PRIVATE CPRGNU NAMING=_ADD_UNDERSCORE FORTRANUNDERSCORE)
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
  target_compile_definitions(ACCESS3_timing PRIVATE CPRINTEL NAMING=_ADD_UNDERSCORE FORTRANUNDERSCORE)
endif()
target_link_libraries(ACCESS3_timing PRIVATE ESMF::ESMF)
target_sources(ACCESS3_timing PRIVATE
  timing/f_wrappers.c
  timing/gptl.c
  timing/GPTLget_memusage.c
  timing/gptl.h
  timing/gptl.inc
  timing/gptl_papi.c
  timing/GPTLprint_memusage.c
  timing/GPTLutil.c
  timing/perf_mod.F90
  timing/perf_utils.F90
)

### Install and Export

## share library
set_target_properties(share PROPERTIES
  OUTPUT_NAME access-share
  EXPORT_NAME share
)
install(TARGETS share
  EXPORT Access3Shareshare_Targets
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT Access3Share_RunTime NAMELINK_COMPONENT Access3Share_Development
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT Access3Share_Development
)
# Fortran module files are a special case, as currently there is no standard
# way of handling them in CMake
target_include_directories(share PUBLIC "$<INSTALL_INTERFACE:${CMAKE_INSTALL_MODULEDIR}/access-share>")
get_target_property(share_moddir share Fortran_MODULE_DIRECTORY)
install(DIRECTORY ${share_moddir}/
  DESTINATION ${CMAKE_INSTALL_MODULEDIR}/access-share
  COMPONENT Access3Share_Development
)
install(EXPORT Access3Shareshare_Targets
  FILE Access3ShareshareTargets.cmake
  NAMESPACE Access3::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Access3Share
)

## timing library
set_target_properties(ACCESS3_timing PROPERTIES
  OUTPUT_NAME access-timing
  EXPORT_NAME timing
)
install(TARGETS ACCESS3_timing
  EXPORT Access3Sharetiming_Targets
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT Access3Share_RunTime NAMELINK_COMPONENT Access3Share_Development
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT Access3Share_Development
)
# Fortran module files are a special case, as currently there is no standard
# way of handling them in CMake
target_include_directories(ACCESS3_timing PUBLIC "$<INSTALL_INTERFACE:${CMAKE_INSTALL_MODULEDIR}/access-timing>")
get_target_property(timing_moddir ACCESS3_timing Fortran_MODULE_DIRECTORY)
install(DIRECTORY ${timing_moddir}/
  DESTINATION ${CMAKE_INSTALL_MODULEDIR}/access-timing
  COMPONENT Access3Share_Development
)
install(EXPORT Access3Sharetiming_Targets
  FILE Access3SharetimingTargets.cmake
  NAMESPACE Access3::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Access3Share
)
