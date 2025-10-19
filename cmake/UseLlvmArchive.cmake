# Use llvm-ar with `rcs` so we dont need to setup a separate ranlib.

# Identify compiler is IntelLLVM
# https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER_ID.html
if (NOT (CMAKE_Fortran_COMPILER_ID MATCHES "IntelLLVM"))
    return()
endif()

# set a temp variable to hold the Fortran compiler path
set(_TMP_VAR "")
if (CMAKE_Fortran_COMPILER)
    set(_TMP_VAR "${CMAKE_Fortran_COMPILER}")
endif()

# try to discover full paths to llvm-ar
# https://cmake.org/cmake/help/latest/command/execute_process.html
if (_TMP_VAR)
    execute_process(
        COMMAND "${_TMP_VAR}" -print-prog-name=llvm-ar
        OUTPUT_VARIABLE LLVM_AR_PATH
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
endif()

# enforce llvm-ar
set(CMAKE_AR "${LLVM_AR_PATH}" CACHE FILEPATH "" FORCE)

# write index table via `s` flag, which disables separate ranlib step.
# https://github.com/Kitware/CMake/blob/1c7fe4dc0b47de90bec6918b33f0aca47d688887/Modules/CMakeCInformation.cmake#L152-L162
# https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_ARCHIVE_FINISH.html
# 
set(CMAKE_Fortran_ARCHIVE_CREATE "<CMAKE_AR> rcs <TARGET> <OBJECTS>")
set(CMAKE_Fortran_ARCHIVE_FINISH "")

unset(_TMP_VAR)
