# Copyright ACCESS-NRI and contributors. See the top-level COPYRIGHT file for details.
# SPDX-License-Identifier: Apache-2.0

include(CMakePackageConfigHelpers)

# External packages

find_package(FoX 4.1.2 REQUIRED)
find_package(PIO 2.5.3 REQUIRED COMPONENTS C Fortran)
find_package(NetCDF 4.7.3 REQUIRED C Fortran)
# Code has not been tested with older PIO/NetCDF versions , but probably still works fine

# Main definitions

# Some code shared by several components
add_subdirectory(share)

# Data component (CDEPS)
add_subdirectory(CDEPS)

# Mediator component (CMEPS)
add_subdirectory(CMEPS)

# make some common deps available
target_link_libraries(share PUBLIC ESMF::ESMF PIO::PIO_Fortran PIO::PIO_C NetCDF::NetCDF_Fortran NetCDF::NetCDF_C)

# Install/Export
# Note that the installation of some components is done in the corresponding subdirectory

configure_package_config_file(
    cmake/Access3ShareConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/Access3ShareConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Access3Share
  )
install(FILES ${CMAKE_SOURCE_DIR}/cmake/FindFoX.cmake ${CMAKE_SOURCE_DIR}/cmake/FindNetCDF.cmake ${CMAKE_SOURCE_DIR}/cmake/FindPIO.cmake ${CMAKE_SOURCE_DIR}/cmake/FindESMF.cmake ${CMAKE_CURRENT_BINARY_DIR}/Access3ShareConfig.cmake
DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Access3Share
COMPONENT Access3Share
)