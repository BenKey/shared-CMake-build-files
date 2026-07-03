macro(set_highest_cxx_standard)
  if("cxx_std_26" IN_LIST CMAKE_CXX_COMPILE_FEATURES AND NOT CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
    set(CMAKE_CXX_STANDARD 26)
  elseif("cxx_std_23" IN_LIST CMAKE_CXX_COMPILE_FEATURES)
    set(CMAKE_CXX_STANDARD 23)
  else()
    set(CMAKE_CXX_STANDARD 20)
  endif()
endmacro()

macro(get_sunos_bits)
  set(SunOS_Bits "Unknown")
  if(${CMAKE_SYSTEM_NAME} STREQUAL "SunOS")
    execute_process(COMMAND isainfo -b OUTPUT_VARIABLE SunOS_Bits ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
  endif()
endmacro()

get_sunos_bits()
set_highest_cxx_standard()
set(CMAKE_CXX_STANDARD_REQUIRED True)

message(STATUS "Before clear:")
message(STATUS "* CMAKE_C_FLAGS: ${CMAKE_C_FLAGS}")
message(STATUS "* CMAKE_C_FLAGS_DEBUG: ${CMAKE_C_FLAGS_DEBUG}")
message(STATUS "* CMAKE_C_FLAGS_RELEASE: ${CMAKE_C_FLAGS_RELEASE}")
message(STATUS "* CMAKE_C_FLAGS_RELWITHDEBINFO: ${CMAKE_C_FLAGS_RELWITHDEBINFO}")
message(STATUS "* CMAKE_C_FLAGS_MINSIZEREL: ${CMAKE_C_FLAGS_MINSIZEREL}")
message(STATUS "* CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
message(STATUS "* CMAKE_CXX_FLAGS_DEBUG: ${CMAKE_CXX_FLAGS_DEBUG}")
message(STATUS "* CMAKE_CXX_FLAGS_RELEASE: ${CMAKE_CXX_FLAGS_RELEASE}")
message(STATUS "* CMAKE_CXX_FLAGS_RELWITHDEBINFO: ${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
message(STATUS "* CMAKE_CXX_FLAGS_MINSIZEREL: ${CMAKE_CXX_FLAGS_MINSIZEREL}")

set(CMAKE_C_FLAGS_DEBUG "" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_RELEASE "" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_RELWITHDEBINFO "" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_MINSIZEREL "" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_DEBUG "" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_RELEASE "" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_MINSIZEREL "" CACHE STRING "" FORCE)

set(_SHARED_COMPILE_DEFINITIONS "")
set(_SHARED_COMPILE_OPTIONS "")
set(_SHARED_LINK_OPTIONS "")

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  list(APPEND _SHARED_COMPILE_DEFINITIONS
    "$<$<CONFIG:Debug>:_DEBUG=1>" "$<$<CONFIG:Debug>:DEBUG=1>"
    "$<$<CONFIG:Release>:NDEBUG=1>")
  list(APPEND _SHARED_COMPILE_OPTIONS
    "-Wall" "-Wconversion" "-Weffc++" "-Wextra" "-Wfloat-equal" "-Wpedantic" "-Wshadow" "-Wsign-conversion"
    "$<$<CONFIG:Debug>:-g3>" "$<$<CONFIG:Debug>:-O0>"
    "$<$<CONFIG:Release>:-g0>" "$<$<CONFIG:Release>:-O2>"
    "$<$<CONFIG:RelWithDebInfo>:-g3>" "$<$<CONFIG:RelWithDebInfo>:-O2>"
    "$<$<CONFIG:MinSizeRel>:-g0>" "$<$<CONFIG:MinSizeRel>:-Os>")
  if(WIN32)
    list(APPEND _SHARED_COMPILE_DEFINITIONS "_UNICODE" "_WINDOWS" "UNICODE")
    list(APPEND _SHARED_COMPILE_OPTIONS "-mwin32" "-mthreads" "-mcrtdll=ucrt")
    list(APPEND _SHARED_LINK_OPTIONS "-mcrtdll=ucrt" "-lucrt")
  else()
    list(APPEND _SHARED_COMPILE_OPTIONS "-pthread")
  endif()
  if(CMAKE_SYSTEM_NAME STREQUAL "SunOS")
    list(APPEND _SHARED_COMPILE_OPTIONS "-m${SunOS_Bits}")
  endif()
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang" AND NOT CMAKE_CXX_SIMULATE_ID STREQUAL "MSVC")
  list(APPEND _SHARED_COMPILE_DEFINITIONS
    "$<$<CONFIG:Debug>:_DEBUG=1>" "$<$<CONFIG:Debug>:DEBUG=1>"
    "$<$<CONFIG:Release>:NDEBUG=1>")
  list(APPEND _SHARED_COMPILE_OPTIONS 
    "-Wall" "-Wconversion" "-Weffc++" "-Wextra" "-Wfloat-equal" "-Wpedantic" "-Wshadow" "-Wsign-conversion"
    "$<$<CONFIG:Debug>:-g3>" "$<$<CONFIG:Debug>:-O0>"
    "$<$<CONFIG:Release>:-g0>" "$<$<CONFIG:Release>:-O2>"
    "$<$<CONFIG:RelWithDebInfo>:-g3>" "$<$<CONFIG:RelWithDebInfo>:-O2>"
    "$<$<CONFIG:MinSizeRel>:-g0>" "$<$<CONFIG:MinSizeRel>:-Os>")
  if(WIN32)
    list(APPEND _SHARED_COMPILE_DEFINITIONS "_UNICODE" "_WINDOWS" "UNICODE")
  else()
    list(APPEND _SHARED_COMPILE_OPTIONS "-pthread")
  endif()
  if(CMAKE_SYSTEM_NAME STREQUAL "SunOS")
    list(APPEND _SHARED_COMPILE_OPTIONS "-m${SunOS_Bits}")
  endif()
elseif(CMAKE_CXX_COMPILER_ID MATCHES "SunPro" AND CMAKE_SYSTEM_NAME STREQUAL "SunOS")
  list(APPEND _SHARED_COMPILE_DEFINITIONS
    "$<$<CONFIG:Debug>:_DEBUG=1>" "$<$<CONFIG:Debug>:DEBUG=1>"
    "$<$<CONFIG:Release>:NDEBUG=1>")
  list(APPEND _SHARED_COMPILE_OPTIONS
    "-m${SunOS_Bits}" "-w"
    "$<$<CONFIG:Debug>:-g3>" "$<$<CONFIG:Debug>:-O0>"
    "$<$<CONFIG:Release>:-O2>"
    "$<$<CONFIG:RelWithDebInfo>:-g3>" "$<$<CONFIG:RelWithDebInfo>:-O2>"
    "$<$<CONFIG:MinSizeRel>:-O2>")
elseif(MSVC OR (CMAKE_CXX_COMPILER_ID MATCHES "Clang" AND CMAKE_CXX_SIMULATE_ID STREQUAL "MSVC"))
  list(APPEND _SHARED_COMPILE_DEFINITIONS 
    "_UNICODE=1" "UNICODE=1" "MSVC=1" "CODE_ANALYSIS=1" "_CRT_NONSTDC_NO_WARNINGS=1" "_CRT_SECURE_NO_WARNINGS=1"
    "BOOST_USE_WINDOWS_H=1" "PSAPI_VERSION=2" "WIN64=1"
    "$<$<CONFIG:Debug>:_DEBUG=1>" "$<$<CONFIG:Debug>:DEBUG=1>"
    "$<$<CONFIG:Release>:NDEBUG=1>")
  list(APPEND _SHARED_COMPILE_OPTIONS
    "-nologo" "-utf-8" "-W4" "-wd4100" "-wd4127" "-wd4503" "-wd4875" "-WX-" "-permissive-" "-sdl" "-fp:precise"
    "-Zc:__cplusplus" "-Zc:forScope" "-Zc:rvalueCast" "-Zc:wchar_t"
    "$<$<CONFIG:Debug>:-Ob0>" "$<$<CONFIG:Debug>:-Od>" "$<$<CONFIG:Debug>:-Zi>"
    "$<$<CONFIG:Release>:-Ob2>" "$<$<CONFIG:Release>:-O2>" "$<$<CONFIG:Release>:-Zc:inline>" "$<$<CONFIG:Release>:-Zc:throwingNew>"
    "$<$<CONFIG:RelWithDebInfo>:-Ob1>" "$<$<CONFIG:RelWithDebInfo>:-O2>" "$<$<CONFIG:RelWithDebInfo>:-Zc:inline>" "$<$<CONFIG:RelWithDebInfo>:-Zc:throwingNew>" "$<$<CONFIG:RelWithDebInfo>:-Zi>"
    "$<$<CONFIG:MinSizeRel>:-Ob1>" "$<$<CONFIG:MinSizeRel>:-O1>" "$<$<CONFIG:MinSizeRel>:-Zc:inline>" "$<$<CONFIG:MinSizeRel>:-Zc:throwingNew>")
endif()

if(_SHARED_COMPILE_OPTIONS)
  add_compile_options(${_SHARED_COMPILE_OPTIONS})
endif()
if(_SHARED_COMPILE_DEFINITIONS)
  add_compile_definitions(${_SHARED_COMPILE_DEFINITIONS})
endif()
if(_SHARED_LINK_OPTIONS)
  add_link_options(${_SHARED_LINK_OPTIONS})
endif()

message(STATUS "Applied global flags for compiler ${CMAKE_CXX_COMPILER_ID}")
if(_SHARED_COMPILE_DEFINITIONS)
  message(STATUS "* _SHARED_COMPILE_DEFINITIONS: ${_SHARED_COMPILE_DEFINITIONS}")
endif()
if(_SHARED_COMPILE_OPTIONS)
  message(STATUS "* _SHARED_COMPILE_OPTIONS: ${_SHARED_COMPILE_OPTIONS}")
endif()
if(_SHARED_LINK_OPTIONS)
  message(STATUS "* _SHARED_LINK_OPTIONS: ${_SHARED_LINK_OPTIONS}")
endif()
message(STATUS "* CMAKE_CXX_STANDARD: ${CMAKE_CXX_STANDARD}")

unset(_SHARED_COMPILE_OPTIONS)
unset(_SHARED_COMPILE_DEFINITIONS)
unset(_SHARED_LINK_OPTIONS)
