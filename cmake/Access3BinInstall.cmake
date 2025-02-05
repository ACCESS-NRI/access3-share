#[==============================================================================[
#                                   Options                                     #
#]==============================================================================]

# Configurations to build
# TO-DO add UM
list(APPEND KnownConfigurations MOM6 CICE6 WW3 MOM6-CICE6 CICE6-WW3 MOM6-WW3 MOM6-CICE6-WW3)
set(BuildConfigurations) 

# Check validity of requested components
foreach(_conf IN LISTS BuildConfigurations)
  if (NOT _conf IN_LIST KnownConfigurations)
      message (FATAL_ERROR "Unsupported configuration: ${_conf}") 
  endif()
endforeach()

option(ENABLE_MOM6           "Build MOM6 configuration" OFF)
option(ENABLE_CICE6          "Build CICE6 configuration" OFF)
option(ENABLE_WW3            "Build WW3 configuration" OFF)
option(ENABLE_MOM6-WW3       "Build MOM6-WW3 configuration" OFF)
option(ENABLE_MOM6-CICE6     "Build MOM6-CICE6 configuration" OFF)
option(ENABLE_CICE6-WW3      "Build CICE6-WW3 configuration" OFF)
option(ENABLE_MOM6-CICE6-WW3 "Build MOM6-CICE6-WW3 configuration" OFF)

message(STATUS "BuildConfigurations")
message(STATUS "${BuildConfigurations}")

# Do not build try to include that are not going to be used
if(MOM6 IN_LIST BuildConfigurations OR MOM6-CICE6 IN_LIST BuildConfigurations OR MOM6-WW3 IN_LIST BuildConfigurations OR MOM6-CICE6-WW3 IN_LIST BuildConfigurations)
  set(ENABLE_MOM6 ON)
else()
  set(ENABLE_MOM6 OFF)
endif()
if(CICE6 IN_LIST BuildConfigurations OR MOM6-CICE6 IN_LIST BuildConfigurations OR CICE6-WW3 IN_LIST BuildConfigurations OR MOM6-CICE6-WW3 IN_LIST BuildConfigurations)
  set(ENABLE_CICE6 ON)
else()
  set(ENABLE_CICE6 OFF)
endif()
if(WW3 IN_LIST BuildConfigurations OR MOM6-WW3 IN_LIST BuildConfigurations OR CICE6-WW3 IN_LIST BuildConfigurations OR MOM6-CICE6-WW3 IN_LIST BuildConfigurations)
  set(ENABLE_WW3 ON)
else()
  set(ENABLE_WW3 OFF)
endif()
if(NOT (ENABLE_MOM6 OR ENABLE_CICE6 OR ENABLE_WW3))
  message (FATAL_ERROR "No model components have been requested, atleast one ENABLE_ configuration must be set")
endif()

# External packages
find_package(Access3Share REQUIRED cdeps cmeps nuopc_cap_share share timing) 
if(ENABLE_CICE6)
  find_package(Cicelib REQUIRED COMPONENTS AccessCICECmeps_Development)
endif()
if(ENABLE_MOM6)
  find_package(MOM6lib REQUIRED AccessMOM6Cmeps_Development)
endif()
if(ENABLE_WW3)
  find_package(AccessWW3Cmeps REQUIRED AccessWW3Cmeps_Development)
endif()

# Main Definitions

# Add executable for each enabled configuration
foreach(CONF IN LISTS BuildConfigurations)

  set(ComponentsTargets "")
  if(OM3_${CONF} MATCHES MOM6)
      list(APPEND ComponentsTargets Access3::mom6lib)
  else()
      list(APPEND ComponentsTargets Access3::cdeps-docn)
  endif()
  if(OM3_${CONF} MATCHES CICE6)
      list(APPEND ComponentsTargets Access3::cicelib)
  else()
      list(APPEND ComponentsTargets Access3::cdeps-dice)
  endif()
  if(OM3_${CONF} MATCHES WW3)
      list(APPEND ComponentsTargets AccessWw3::ww3-cmeps)
  else()
      list(APPEND ComponentsTargets Access3::cdeps-dwav)
  endif()

  # We use the CESM driver from CMEPS
  add_fortran_library(OM3_cesm_driver_${CONF} mod/OM3_cesm_driver_${CONF} STATIC
      CMEPS/CMEPS/cesm/driver/esm.F90
      CMEPS/CMEPS/cesm/driver/ensemble_driver.F90
      CMEPS/CMEPS/cesm/driver/esm_time_mod.F90
  )
  target_link_libraries(OM3_cesm_driver_${CONF}
      PUBLIC esmf
      PRIVATE ${ComponentsTargets} Access3::cdeps-drof Access3::cdeps-datm Access3::cmeps Access3::nuopc_cap_share Access3::share Access3::timing
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
  target_link_libraries(OM3_${CONF} PRIVATE OM3_cesm_driver_${CONF} Access3::share esmf)

  set_target_properties(OM3_${CONF} PROPERTIES
      LINKER_LANGUAGE Fortran
      OUTPUT_NAME access-om3-${CONF}
  )
endforeach()

# Install

foreach(CONF IN LISTS BuildConfigurations)

  install(TARGETS OM3_${CONF}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  )
endforeach()
