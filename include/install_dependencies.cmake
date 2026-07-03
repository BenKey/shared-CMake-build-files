if(POLICY CMP0207)
  cmake_policy(PUSH)
  cmake_policy(SET CMP0207 NEW)
endif()

if(NOT DEFINED APP_RUNTIME_DEPENDENCY_SUBDIR)
  if(WIN32)
    set(APP_RUNTIME_DEPENDENCY_SUBDIR "bin")
  else()
    set(APP_RUNTIME_DEPENDENCY_SUBDIR "lib")
  endif()
endif()
if(NOT DEFINED APP_RUNTIME_DEPENDENCY_DIR)
  set(APP_RUNTIME_DEPENDENCY_DIR "${CMAKE_INSTALL_PREFIX}/${APP_RUNTIME_DEPENDENCY_SUBDIR}")
endif()
message(STATUS "App runtime dependency directory: ${APP_RUNTIME_DEPENDENCY_DIR}")

file(
  GET_RUNTIME_DEPENDENCIES
  EXECUTABLES "${TARGET_FILE}"
  DIRECTORIES ${RUNTIME_DEPENDENCIES_DIRECTORIES}
  PRE_EXCLUDE_REGEXES
    "^libc\\.so"
    "^libc\\+\\+\\.so"
    "^libcxxrt\\.so"
    "^libgcc_s\\.so"
    "^ld-linux"
    "^libm\\.so"
    "^librt\\.so"
    "^libthr\\.so"
    "^libutil\\.so"
  RESOLVED_DEPENDENCIES_VAR
    resolved_libs
  UNRESOLVED_DEPENDENCIES_VAR
    unresolved_libs
)

list(FILTER unresolved_libs EXCLUDE REGEX "^api-ms-win")
list(FILTER unresolved_libs EXCLUDE REGEX "^ext-ms-")

foreach(unresolved IN LISTS unresolved_libs)
  message(WARNING "The following dependency could not be resolved: ${unresolved}")
endforeach()

foreach(lib IN LISTS resolved_libs)
  file(INSTALL
    DESTINATION "${APP_RUNTIME_DEPENDENCY_DIR}"
    TYPE SHARED_LIBRARY
    FOLLOW_SYMLINK_CHAIN
    FILES "${lib}"
  )
endforeach()

if(POLICY CMP0207)
  cmake_policy(POP)
endif()
