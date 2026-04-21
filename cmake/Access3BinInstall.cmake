# Copyright ACCESS-NRI and contributors. See the top-level COPYRIGHT file for details.
# SPDX-License-Identifier: Apache-2.0

#[==============================================================================[
#                                   Options                                     #
#]==============================================================================]

# These combinations are known to build. Other combinations of MOM6-CICE6-WW3-UM13
# would be possible
list(APPEND KnownConfigurations 
  MOM6 CICE6 WW3 MOM6-CICE6 CICE6-WW3 MOM6-WW3 MOM6-CICE6-WW3 MOM6-UM13 MOM6-CICE6-UM13
)
set(BuildConfigurations) # Configurations to build

option(ENABLE_MOM6           "Build MOM6 configuration" OFF)
option(ENABLE_CICE6          "Build CICE6 configuration" OFF)
option(ENABLE_WW3            "Build WW3 configuration" OFF)
option(ENABLE_UM13           "Build UM13 configuration" OFF)

# Check validity of requested components
foreach(_conf IN LISTS BuildConfigurations)
  if (NOT _conf IN_LIST KnownConfigurations)
      message (FATAL_ERROR "Unsupported configuration: ${_conf}") 
  endif()
  if (_conf MATCHES MOM6)
    set(ENABLE_MOM6  ON)
  endif()
  if (_conf MATCHES CICE6)
    set(ENABLE_CICE6 ON)
  endif()
  if (_conf MATCHES WW3)
    set(ENABLE_WW3   ON)
  endif()
  if (_conf MATCHES UM13)
    set(ENABLE_UM13   ON)
  endif()
endforeach()

message(STATUS "BuildConfigurations")
message(STATUS "${BuildConfigurations}")
message(STATUS "  - MOM6              ${ENABLE_MOM6}")
message(STATUS "  - CICE6             ${ENABLE_CICE6}")
message(STATUS "  - WW3               ${ENABLE_WW3}")
message(STATUS "  - UM13              ${ENABLE_UM13}")


if(NOT (ENABLE_MOM6 OR ENABLE_CICE6 OR ENABLE_WW3 OR ENABLE_UM13))
  message (FATAL_ERROR "No model components have been requested, atleast one ENABLE_ configuration must be set")
endif()

# External packages
find_package(Access3Share REQUIRED cdeps cmeps nuopc_cap_share share timing) 
if(ENABLE_CICE6)
  find_package(Cicelib REQUIRED COMPONENTS AccessCICECmeps_Development)
endif()
if(ENABLE_MOM6)
  find_package(Mom6lib REQUIRED AccessMOM6Cmeps_Development)
endif()
if(ENABLE_WW3)
  find_package(Ww3lib REQUIRED AccessWW3Cmeps_Development)
endif()
if(ENABLE_UM13)
  find_package(PkgConfig REQUIRED)
  pkg_check_modules(UM REQUIRED IMPORTED_TARGET "libum-atmos")
  pkg_check_modules(GCOM REQUIRED IMPORTED_TARGET "libgcom")
endif()

# Main Definitions

# Add executable for each enabled configuration
foreach(CONF IN LISTS BuildConfigurations)

  set(ComponentsTargets "")
  set(CompileDefinitions MED_PRESENT)
  if(CONF MATCHES MOM6)
      list(APPEND ComponentsTargets Access3::mom6lib)
  else()
      list(APPEND ComponentsTargets Access3::cdeps-docn)
  endif()
  list(APPEND CompileDefinitions OCN_PRESENT)

  if(CONF MATCHES CICE6)
      list(APPEND ComponentsTargets Access3::cicelib)
  else()
      list(APPEND ComponentsTargets Access3::cdeps-dice)
  endif()
  list(APPEND CompileDefinitions ICE_PRESENT)

  if(CONF MATCHES WW3)
      list(APPEND ComponentsTargets Access3::ww3lib)
  else()
      list(APPEND ComponentsTargets Access3::cdeps-dwav)
  endif()
  list(APPEND CompileDefinitions WAV_PRESENT)

  if(CONF MATCHES UM13)
      list(APPEND ComponentsTargets PkgConfig::UM PkgConfig::GCOM)
      list(APPEND CompileDefinitions ATM_PRESENT)
  else()
      list(APPEND ComponentsTargets Access3::cdeps-drof Access3::cdeps-datm)
      list(APPEND CompileDefinitions ATM_PRESENT ROF_PRESENT)
  endif()

  # We use the CESM driver from CMEPS
  add_fortran_library(cesm_driver_${CONF} mod/cesm_driver_${CONF} STATIC
      CMEPS/CMEPS/cesm/driver/esm.F90
      CMEPS/CMEPS/cesm/driver/ensemble_driver.F90
      CMEPS/CMEPS/cesm/driver/esm_time_mod.F90
  )

  target_link_libraries(cesm_driver_${CONF}
      PUBLIC ESMF::ESMF
      PRIVATE ${ComponentsTargets} Access3::cmeps Access3::nuopc_cap_share Access3::share Access3::timing
  )
  target_compile_definitions(cesm_driver_${CONF} PRIVATE ${CompileDefinitions}
                                                             $<$<CONFIG:Debug>:DEBUG>
  )

  add_executable(${CONF} CMEPS/CMEPS/cesm/driver/esmApp.F90)
  target_link_libraries(${CONF} PRIVATE cesm_driver_${CONF} Access3::share ESMF::ESMF)

  if (ENABLE_MOM6)
    set(BinName access-om3-${CONF})
  else()
    set(BinName access3-${CONF})
  endif()

  set_target_properties(${CONF} PROPERTIES
      LINKER_LANGUAGE Fortran
      OUTPUT_NAME ${BinName}
  )
endforeach()

# Install

foreach(CONF IN LISTS BuildConfigurations)

  install(TARGETS ${CONF}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  )
endforeach()
