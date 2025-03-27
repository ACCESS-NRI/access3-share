# Copyright ACCESS-NRI and contributors. See the top-level COPYRIGHT file for details.
# SPDX-License-Identifier: Apache-2.0

### Targets

## CMEPS library
add_fortran_library(ACCESS3_cmeps mod/cmeps STATIC)
add_library(Access3::cmeps ALIAS ACCESS3_cmeps)
target_link_libraries(ACCESS3_cmeps
  PUBLIC ESMF::ESMF
  PRIVATE Access3::nuopc_cap_share Access3::share Access3::timing
)
if(OpenMP_Fortran_FOUND)
  target_link_libraries(ACCESS3_cmeps PRIVATE OpenMP::OpenMP_Fortran)
endif()
target_sources(ACCESS3_cmeps PRIVATE
  CMEPS/cesm/flux_atmocn/shr_flux_mod.F90
  CMEPS/mediator/med_phases_history_mod.F90
  CMEPS/mediator/med_phases_restart_mod.F90
  CMEPS/mediator/med_map_mod.F90
  CMEPS/mediator/med_methods_mod.F90
  CMEPS/mediator/med_phases_prep_ice_mod.F90
  CMEPS/mediator/med_phases_prep_glc_mod.F90
  CMEPS/mediator/med_internalstate_mod.F90
  CMEPS/mediator/med_phases_profile_mod.F90
  CMEPS/mediator/esmFldsExchange_hafs_mod.F90
  CMEPS/mediator/med_phases_prep_rof_mod.F90
  CMEPS/mediator/esmFldsExchange_cesm_mod.F90
  CMEPS/mediator/med_merge_mod.F90
  CMEPS/mediator/med_constants_mod.F90
  CMEPS/mediator/med_kind_mod.F90
  CMEPS/mediator/esmFldsExchange_ufs_mod.F90
  CMEPS/mediator/med_phases_prep_lnd_mod.F90
  CMEPS/mediator/med_phases_prep_atm_mod.F90
  CMEPS/mediator/med_phases_prep_ocn_mod.F90
  CMEPS/mediator/esmFlds.F90
  CMEPS/mediator/med.F90
  CMEPS/mediator/med_phases_ocnalb_mod.F90
  CMEPS/mediator/med_phases_prep_wav_mod.F90
  CMEPS/mediator/med_utils_mod.F90
  CMEPS/mediator/med_fraction_mod.F90
  CMEPS/mediator/med_phases_aofluxes_mod.F90
  CMEPS/mediator/med_io_mod.F90
  CMEPS/mediator/med_diag_mod.F90
  CMEPS/mediator/med_phases_post_atm_mod.F90
  CMEPS/mediator/med_phases_post_ice_mod.F90
  CMEPS/mediator/med_phases_post_ocn_mod.F90
  CMEPS/mediator/med_phases_post_lnd_mod.F90
  CMEPS/mediator/med_phases_post_glc_mod.F90
  CMEPS/mediator/med_phases_post_rof_mod.F90
  CMEPS/mediator/med_phases_post_wav_mod.F90
)

## NUOPC cap share
add_fortran_library(ACCESS3_nuopc_cap_share mod/nuopc_cap_share STATIC)
add_library(Access3::nuopc_cap_share ALIAS ACCESS3_nuopc_cap_share)
target_link_libraries(ACCESS3_nuopc_cap_share
  PUBLIC ESMF::ESMF
  PRIVATE Access3::share
)
target_sources(ACCESS3_nuopc_cap_share PRIVATE
  CMEPS/cesm/nuopc_cap_share/driver_pio_mod.F90
  CMEPS/cesm/nuopc_cap_share/esm_utils_mod.F90
  CMEPS/cesm/nuopc_cap_share/glc_elevclass_mod.F90
)


### Install and Export

## CMEPS library
set_target_properties(ACCESS3_cmeps PROPERTIES
  OUTPUT_NAME access-cmeps
  EXPORT_NAME cmeps
)
install(TARGETS ACCESS3_cmeps
  EXPORT Access3Sharecmeps_Targets
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT Access3Share_RunTime NAMELINK_COMPONENT Access3Share_Development
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT Access3Share_Development
)
# Fortran module files are a special case, as currently there is no standard
# way of handling them in CMake
target_include_directories(ACCESS3_cmeps PUBLIC "$<INSTALL_INTERFACE:${CMAKE_INSTALL_MODULEDIR}/access-cmeps>")
get_target_property(cmeps_moddir ACCESS3_cmeps Fortran_MODULE_DIRECTORY)
install(FILES ${cmeps_moddir}/med.mod ${cmeps_moddir}/med_internalstate_mod.mod
  DESTINATION ${CMAKE_INSTALL_MODULEDIR}/access-cmeps
  COMPONENT Access3Share_Development
)
install(EXPORT Access3Sharecmeps_Targets
  FILE Access3SharecmepsTargets.cmake
  NAMESPACE Access3::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Access3Share
)

## NUOPC cap share
set_target_properties(ACCESS3_nuopc_cap_share PROPERTIES
  OUTPUT_NAME access-nuopc_cap_share
  EXPORT_NAME nuopc_cap_share
)
install(TARGETS ACCESS3_nuopc_cap_share
  EXPORT Access3Sharenuopc_cap_share_Targets
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT Access3Share_RunTime NAMELINK_COMPONENT Access3Share_Development
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT Access3Share_Development
)
# Fortran module files are a special case, as currently there is no standard
# way of handling them in CMake
target_include_directories(ACCESS3_nuopc_cap_share PUBLIC "$<INSTALL_INTERFACE:${CMAKE_INSTALL_MODULEDIR}/access-nuopc_cap_share>")
get_target_property(nuopc_cap_share_moddir ACCESS3_nuopc_cap_share Fortran_MODULE_DIRECTORY)
install(DIRECTORY ${nuopc_cap_share_moddir}/
  DESTINATION ${CMAKE_INSTALL_MODULEDIR}/access-nuopc_cap_share
  COMPONENT Access3Share_Development
)
install(EXPORT Access3Sharenuopc_cap_share_Targets
  FILE Access3Sharenuopc_cap_shareTargets.cmake
  NAMESPACE Access3::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Access3Share
)
