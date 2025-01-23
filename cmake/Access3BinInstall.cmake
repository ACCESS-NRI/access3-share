#[==============================================================================[
#                                   Options                                     #
#]==============================================================================]

# Configurations to build
# TO-DO add UM
list(APPEND KnownConfigurations MOM6 CICE6 WW3 MOM6-CICE6 CICE6-WW3 MOM6-WW3 MOM6-CICE6-WW3)

option(ENABLE_MOM6           "Build MOM6 configuration" OFF)
option(ENABLE_CICE6          "Build CICE6 configuration" OFF)
option(ENABLE_WW3            "Build WW3 configuration" OFF)
option(ENABLE_MOM6-WW3       "Build MOM6-WW3 configuration" OFF)
option(ENABLE_MOM6-CICE6     "Build MOM6-CICE6 configuration" OFF)
option(ENABLE_CICE6-WW3      "Build CICE6-WW3 configuration" OFF)
option(ENABLE_MOM6-CICE6-WW3 "Build MOM6-CICE6-WW3 configuration" OFF)

message(STATUS "Configurations")
message(STATUS "  - MOM6              ${ENABLE_MOM6}")
message(STATUS "  - CICE6             ${ENABLE_CICE6}")
message(STATUS "  - WW3               ${ENABLE_WW3}")
message(STATUS "  - MOM6-WW3          ${ENABLE_MOM6-WW3}")
message(STATUS "  - MOM6-CICE6        ${ENABLE_MOM6-CICE6}")
message(STATUS "  - CICE6-WW3         ${ENABLE_CICE6-WW3}")
message(STATUS "  - MOM6-CICE6-WW3    ${ENABLE_MOM6-CICE6-WW3}")

# Do not build try to include that are not going to be used
if(ENABLE_MOM6 OR ENABLE_MOM6-CICE6 OR ENABLE_MOM6-WW3 OR ENABLE_MOM6-CICE6-WW3)
  set(ENABLE_MOM6 ON)
else()
  set(ENABLE_MOM6 OFF)
endif()
if(ENABLE_CICE6 OR ENABLE_MOM6-CICE6 OR ENABLE_CICE6-WW3 OR ENABLE_MOM6-CICE6-WW3)
  set(ENABLE_CICE6 ON)
else()
  set(ENABLE_CICE6 OFF)
endif()
if(ENABLE_WW3 OR ENABLE_MOM6-WW3 OR ENABLE_CICE6-WW3 OR ENABLE_MOM6-CICE6-WW3)
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
#TO-DO remove hardcoded IO_PIO ?
  find_package(Cicelib REQUIRED COMPONENTS AccessCiceCmeps_Development IO_PIO)
endif()
if(ENABLE_MOM6)
  find_package(mom6lib REQUIRED AccessMOM6Cmeps_Development)
endif()
if(ENABLE_WW3)
  find_package(AccessWW3Cmeps REQUIRED AccessWW3Cmeps_Development)
endif()

# Main Definitions

# Add executable for each enabled configuration
foreach(CONF IN LISTS KnownConfigurations)
  if(NOT ENABLE_${CONF})
      continue()
  endif()

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

foreach(CONF IN LISTS KnownConfigurations)
  if(NOT ENABLE_${CONF})
    continue()
  endif()

  install(TARGETS OM3_${CONF}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  )
endforeach()
