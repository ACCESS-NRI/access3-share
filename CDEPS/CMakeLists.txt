# Copyright ACCESS-NRI and contributors. See the top-level COPYRIGHT file for details.
# SPDX-License-Identifier: Apache-2.0

### Targets

## Common library
add_fortran_library(ACCESS3_cdeps_common mod/common STATIC)
add_library(Access3::cdeps_common ALIAS ACCESS3_cdeps_common)
target_include_directories(ACCESS3_cdeps_common PRIVATE $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/fox/include>)
target_link_libraries(ACCESS3_cdeps_common
  PUBLIC ESMF::ESMF
  PRIVATE Access3::share Access3::cmeps Access3::nuopc_cap_share FoX::FoX
)
target_sources(ACCESS3_cdeps_common PRIVATE
  CDEPS/streams/dshr_methods_mod.F90
  CDEPS/streams/dshr_strdata_mod.F90
  CDEPS/streams/dshr_stream_mod.F90
  CDEPS/streams/dshr_tinterp_mod.F90

  CDEPS/dshr/dshr_mod.F90
  CDEPS/dshr/dshr_dfield_mod.F90
  CDEPS/dshr/dshr_fldlist_mod.F90
)
add_patched_source(ACCESS3_cdeps_common CDEPS/streams/dshr_strdata_mod.F90)


## DATM
add_fortran_library(ACCESS3_cdeps_datm mod/datm STATIC)
add_library(Access3::cdeps_datm ALIAS ACCESS3_cdeps_datm)
target_include_directories(ACCESS3_cdeps_datm PRIVATE $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/fox/include>)
target_link_libraries(ACCESS3_cdeps_datm
  PUBLIC ESMF::ESMF
  PRIVATE Access3::cdeps_common Access3::share
)
target_sources(ACCESS3_cdeps_datm PRIVATE
  CDEPS/datm/datm_datamode_clmncep_mod.F90
  CDEPS/datm/datm_datamode_core2_mod.F90
  CDEPS/datm/datm_datamode_cplhist_mod.F90
  CDEPS/datm/datm_datamode_era5_mod.F90
  CDEPS/datm/datm_datamode_gefs_mod.F90
  CDEPS/datm/datm_datamode_jra_mod.F90
  CDEPS/datm/datm_datamode_simple_mod.F90
  extra_sources/datm_datamode_jra55do_mod.F90
)
add_patched_source(ACCESS3_cdeps_datm CDEPS/datm/atm_comp_nuopc.F90)

## DOCN
add_fortran_library(ACCESS3_cdeps_docn mod/docn STATIC)
add_library(Access3::cdeps_docn ALIAS ACCESS3_cdeps_docn)
target_include_directories(ACCESS3_cdeps_docn PRIVATE $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/fox/include>)
target_link_libraries(ACCESS3_cdeps_docn
  PUBLIC ESMF::ESMF
  PRIVATE Access3::cdeps_common Access3::share
)
target_sources(ACCESS3_cdeps_docn PRIVATE
  CDEPS/docn/docn_datamode_aquaplanet_mod.F90
  CDEPS/docn/docn_datamode_copyall_mod.F90
  CDEPS/docn/docn_datamode_cplhist_mod.F90
  CDEPS/docn/docn_datamode_multilev_mod.F90
  CDEPS/docn/docn_datamode_multilev_dom_mod.F90
  CDEPS/docn/docn_datamode_iaf_mod.F90
  CDEPS/docn/docn_datamode_som_mod.F90
  CDEPS/docn/docn_import_data_mod.F90
  CDEPS/docn/ocn_comp_nuopc.F90
)

## DICE
add_fortran_library(ACCESS3_cdeps_dice mod/dice STATIC)
add_library(Access3::cdeps_dice ALIAS ACCESS3_cdeps_dice)
target_include_directories(ACCESS3_cdeps_dice PRIVATE $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/fox/include>)
target_link_libraries(ACCESS3_cdeps_dice
  PUBLIC ESMF::ESMF
  PRIVATE Access3::cdeps_common Access3::share
)
target_sources(ACCESS3_cdeps_dice PRIVATE
  CDEPS/dice/dice_datamode_cplhist_mod.F90
  CDEPS/dice/dice_datamode_ssmi_mod.F90
  CDEPS/dice/dice_flux_atmice_mod.F90
  CDEPS/dice/ice_comp_nuopc.F90
)

## DWAV
add_fortran_library(ACCESS3_cdeps_dwav mod/dwav STATIC)
add_library(Access3::cdeps_dwav ALIAS ACCESS3_cdeps_dwav)
target_include_directories(ACCESS3_cdeps_dwav PRIVATE $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/fox/include>)
target_link_libraries(ACCESS3_cdeps_dwav
  PUBLIC ESMF::ESMF
  PRIVATE Access3::cdeps_common Access3::share
)
target_sources(ACCESS3_cdeps_dwav PRIVATE
  CDEPS/dwav/wav_comp_nuopc.F90
)

## DROF
add_fortran_library(ACCESS3_cdeps_drof mod/drof STATIC)
add_library(Access3::cdeps_drof ALIAS ACCESS3_cdeps_drof)
target_include_directories(ACCESS3_cdeps_drof PRIVATE $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/fox/include>)
target_link_libraries(ACCESS3_cdeps_drof
  PUBLIC ESMF::ESMF
  PRIVATE Access3::cdeps_common Access3::share
)
target_sources(ACCESS3_cdeps_drof PRIVATE
  CDEPS/drof/rof_comp_nuopc.F90
)

### Install and Export

# cdeps_common
set_target_properties(ACCESS3_cdeps_common PROPERTIES
  OUTPUT_NAME access-cdeps-common
  EXPORT_NAME cdeps-common
)
install(TARGETS ACCESS3_cdeps_common
  EXPORT Access3Sharecdeps_Targets
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT Access3Share_RunTime NAMELINK_COMPONENT Access3Share_Development
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT Access3Share_Development
)
# Fortran module files are a special case, as currently there is no standard
  # way of handling them in CMake
  target_include_directories(ACCESS3_cdeps_common PUBLIC "$<INSTALL_INTERFACE:${CMAKE_INSTALL_MODULEDIR}/access-cdeps-common>")
  get_target_property(common_moddir ACCESS3_cdeps_common Fortran_MODULE_DIRECTORY)
  install(FILES 
    ${common_moddir}/dshr_methods_mod.mod
    ${common_moddir}/dshr_strdata_mod.mod
    ${common_moddir}/dshr_stream_mod.mod
    ${common_moddir}/dshr_tinterp_mod.mod
  
    ${common_moddir}/dshr_dfield_mod.mod
    ${common_moddir}/dshr_fldlist_mod.mod
    ${common_moddir}/dshr_mod.mod
    DESTINATION ${CMAKE_INSTALL_MODULEDIR}/access-cdeps-common
    COMPONENT Access3Share_Development
  )
# components
foreach(LIB atm ocn ice wav rof)
  set_target_properties(ACCESS3_cdeps_d${LIB} PROPERTIES
    OUTPUT_NAME access-cdeps-d${LIB}
    EXPORT_NAME cdeps-d${LIB}
  )
  install(TARGETS ACCESS3_cdeps_d${LIB}
    EXPORT Access3Sharecdeps_Targets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT Access3Share_RunTime NAMELINK_COMPONENT Access3Share_Development
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT Access3Share_Development
  )
  # Fortran module files are a special case, as currently there is no standard
  # way of handling them in CMake
  target_include_directories(ACCESS3_cdeps_d${LIB} PUBLIC "$<INSTALL_INTERFACE:${CMAKE_INSTALL_MODULEDIR}/access-cdeps-d${LIB}>")
  get_target_property(d${LIB}_moddir ACCESS3_cdeps_d${LIB} Fortran_MODULE_DIRECTORY)
  install(FILES ${d${LIB}_moddir}/${LIB}_comp_nuopc.mod
    DESTINATION ${CMAKE_INSTALL_MODULEDIR}/access-cdeps-d${LIB}
    COMPONENT Access3Share_Development
  )
endforeach()
install(EXPORT Access3Sharecdeps_Targets
  FILE Access3SharecdepsTargets.cmake
  NAMESPACE Access3::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Access3Share
)