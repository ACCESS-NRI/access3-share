# Earth System Modeling Framework

# Copyright (c) 2002-2025 University Corporation for Atmospheric Research,
# Massachusetts Institute of Technology, Geophysical Fluid Dynamics Laboratory,
# University of Michigan, National Centers for Environmental Prediction,
# Los Alamos National Laboratory, Argonne National Laboratory,
# NASA Goddard Space Flight Center.
# All rights reserved.

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal with the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#   1. Redistributions of source code must retain the above copyright notice,
#      this list of conditions and the following disclaimers.
#   2. Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimers in the
#      documentation and/or other materials provided with the distribution.
#   3. Neither the names of the organizations developing this software, nor
#      the names of its contributors may be used to endorse or promote products
#      derived from this Software without specific prior written permission.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# WITH THE SOFTWARE.

# - Try to find ESMF
#
# Uses ESMFMKFILE to find the filepath of esmf.mk. If this is NOT set, then this
# module will attempt to find esmf.mk. If ESMFMKFILE exists, then
# ESMF_FOUND=TRUE and all ESMF makefile variables will be set in the global
# scope. Optionally, set ESMF_MKGLOBALS to a string list to filter makefile
# variables. For example, to globally scope only ESMF_LIBSDIR and ESMF_APPSDIR
# variables, use this CMake command in CMakeLists.txt:
#
#   set(ESMF_MKGLOBALS "LIBSDIR" "APPSDIR")

# Set ESMFMKFILE as defined by system env variable. If it's not explicitly set
# try to find esmf.mk file in default locations (ESMF_ROOT, CMAKE_PREFIX_PATH,
# etc)

# - Common Usage
#
# Where to look for this FindESMF.cmake file
#   list(APPEND CMAKE_MODULE_PATH "<PATH_TO_THIS_FILE>")
#   <PATH_TO_THIS_FILE> is to be replaced with the directory for this file
#
# How to locate ESMF libraries and create target
#   find_package(ESMF <X.Y.Z> MODULE REQUIRED)
#   <X.Y.Z> is to be replaced with the minimum version required
#
# How to link targets
#   target_link_libraries(<CMAKE_TARGET> PUBLIC ESMF::ESMF)
#   <CMAKE_TARGET> is to be replaced with your CMake target

if(NOT DEFINED ESMFMKFILE)
  if(NOT DEFINED ENV{ESMFMKFILE})
    find_path(ESMFMKFILE_PATH esmf.mk PATH_SUFFIXES lib lib64)
    if(ESMFMKFILE_PATH)
      set(ESMFMKFILE ${ESMFMKFILE_PATH}/esmf.mk)
      message(STATUS "Found esmf.mk file ${ESMFMKFILE}")
    endif()
  else()
    set(ESMFMKFILE $ENV{ESMFMKFILE})
  endif()
endif()

# Only parse the mk file if it is found
if(EXISTS ${ESMFMKFILE})
  set(ESMFMKFILE ${ESMFMKFILE} CACHE FILEPATH "Path to esmf.mk file")
  set(ESMF_FOUND TRUE CACHE BOOL "esmf.mk file found" FORCE)

  # Read the mk file
  file(STRINGS "${ESMFMKFILE}" esmfmkfile_contents)
  # Parse each line in the mk file
  foreach(str ${esmfmkfile_contents})
    # Only consider uncommented lines
    string(REGEX MATCH "^[^#]" def ${str})
    # Line is not commented
    if(def)
      # Extract the variable name
      string(REGEX MATCH "^[^=]+" esmf_varname ${str})
      # Extract the variable's value
      string(REGEX MATCH "=.+$" esmf_vardef ${str})
      # Only for variables with a defined value
      if(esmf_vardef)
        # Get rid of the assignment string
        string(SUBSTRING ${esmf_vardef} 1 -1 esmf_vardef)
        # Remove whitespace
        string(STRIP ${esmf_vardef} esmf_vardef)
        # A string or single-valued list
        if(NOT DEFINED ESMF_MKGLOBALS)
          # Set in global scope
          set(${esmf_varname} ${esmf_vardef})
          # Don't display by default in GUI
          mark_as_advanced(esmf_varname)
        else() # Need to filter global promotion
          foreach(m ${ESMF_MKGLOBALS})
            string(FIND ${esmf_varname} ${m} match)
            # Found the string
            if(NOT ${match} EQUAL -1)
              # Promote to global scope
              set(${esmf_varname} ${esmf_vardef})
              # Don't display by default in the GUI
              mark_as_advanced(esmf_varname)
              # No need to search for the current string filter
              break()
            endif()
          endforeach()
        endif()
      endif()
    endif()
  endforeach()

  # Construct ESMF_VERSION from ESMF_VERSION_STRING_GIT
  # ESMF_VERSION_MAJOR and ESMF_VERSION_MINOR are defined in ESMFMKFILE
  set(ESMF_VERSION 0)
  set(ESMF_VERSION_PATCH ${ESMF_VERSION_REVISION})
  set(ESMF_BETA_RELEASE FALSE)
  if(ESMF_VERSION_BETASNAPSHOT MATCHES "^('T')$")
    set(ESMF_BETA_RELEASE TRUE)
    if(ESMF_VERSION_STRING_GIT MATCHES "^ESMF.*beta_snapshot")
      set(ESMF_BETA_SNAPSHOT ${ESMF_VERSION_STRING_GIT})
    elseif(ESMF_VERSION_STRING_GIT MATCHES "^v.\..\..b")
      set(ESMF_BETA_SNAPSHOT ${ESMF_VERSION_STRING_GIT})
    else()
      set(ESMF_BETA_SNAPSHOT 0)
    endif()
    message(STATUS "Detected ESMF Beta snapshot: ${ESMF_BETA_SNAPSHOT}")
  endif()
  set(ESMF_VERSION "${ESMF_VERSION_MAJOR}.${ESMF_VERSION_MINOR}.${ESMF_VERSION_PATCH}")

  # Find the ESMF library
  if(USE_ESMF_STATIC_LIBS)
    find_library(ESMF_LIBRARY_LOCATION NAMES libesmf.a PATHS ${ESMF_LIBSDIR} NO_DEFAULT_PATH)
    if(ESMF_LIBRARY_LOCATION MATCHES "ESMF_LIBRARY_LOCATION-NOTFOUND")
      message(WARNING "Static ESMF library (libesmf.a) not found in \
                       ${ESMF_LIBSDIR}. Try setting USE_ESMF_STATIC_LIBS=OFF")
    endif()
    if(NOT TARGET ESMF::ESMF)
      add_library(ESMF::ESMF STATIC IMPORTED)
    endif()
  else()
    find_library(ESMF_LIBRARY_LOCATION NAMES esmf PATHS ${ESMF_LIBSDIR} NO_DEFAULT_PATH)
    if(ESMF_LIBRARY_LOCATION MATCHES "ESMF_LIBRARY_LOCATION-NOTFOUND")
      message(WARNING "ESMF library not found in ${ESMF_LIBSDIR}.")
    endif()
    if(NOT TARGET ESMF::ESMF)
      add_library(ESMF::ESMF UNKNOWN IMPORTED)
    endif()
  endif()

  # Add ESMF as an alias to ESMF::ESMF for backward compatibility
  if(NOT TARGET ESMF)
    add_library(ESMF ALIAS ESMF::ESMF)
  endif()

  # Add ESMF include directories
  set(ESMF_INCLUDE_DIRECTORIES "")
  separate_arguments(_ESMF_F90COMPILEPATHS UNIX_COMMAND ${ESMF_F90COMPILEPATHS})
  foreach(_ITEM ${_ESMF_F90COMPILEPATHS})
    string(REGEX REPLACE "^-I" "" _ITEM "${_ITEM}")
    list(APPEND ESMF_INCLUDE_DIRECTORIES ${_ITEM})
  endforeach()

  # Add ESMF link libraries
  string(STRIP "${ESMF_F90LINKRPATHS} ${ESMF_F90ESMFLINKRPATHS} ${ESMF_F90ESMFLINKPATHS} ${ESMF_F90LINKPATHS} ${ESMF_F90LINKLIBS} ${ESMF_F90LINKOPTS}" ESMF_INTERFACE_LINK_LIBRARIES)

  # Finalize find_package
  include(FindPackageHandleStandardArgs)

  find_package_handle_standard_args(
        ${CMAKE_FIND_PACKAGE_NAME}
        REQUIRED_VARS ESMF_LIBRARY_LOCATION
                      ESMF_INTERFACE_LINK_LIBRARIES
                      ESMF_F90COMPILEPATHS
        VERSION_VAR ESMF_VERSION)

  set_target_properties(ESMF::ESMF PROPERTIES
        IMPORTED_LOCATION "${ESMF_LIBRARY_LOCATION}"
        INTERFACE_INCLUDE_DIRECTORIES "${ESMF_INCLUDE_DIRECTORIES}"
        INTERFACE_LINK_LIBRARIES "${ESMF_INTERFACE_LINK_LIBRARIES}")

else()
  set(ESMF_FOUND FALSE CACHE BOOL "esmf.mk file NOT found" FORCE)
  message(WARNING "ESMFMKFILE ${ESMFMKFILE} not found. Try setting ESMFMKFILE \
                   to esmf.mk location.")
endif()