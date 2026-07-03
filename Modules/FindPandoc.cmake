# The module defines the following variables:
#
#   Pandoc - path to the pandoc executable
#   Pandoc_FOUND      - true if pandoc was found
#   Pandoc_VERSION    - the version of pandoc found

#=============================================================================
# Copyright (C) 2010-2011 Daniel Pfeifer <daniel@pfeifer-mail.de>
#
# Distributed under the Boost Software License, Version 1.0.
# See accompanying file LICENSE_1_0.txt or copy at
#   http://www.boost.org/LICENSE_1_0.txt
#=============================================================================

set(Program_Files_x86_Env_Name "ProgramFiles(x86)")
find_program(Pandoc
  NAMES
  pandoc
  PATHS
  $ENV{PROGRAMFILES}/Pandoc
  $ENV{PROGRAMFILES}/Pandoc/bin
  $ENV{${Program_Files_x86_Env_Name}}/Pandoc/bin
  $ENV{${Program_Files_x86_Env_Name}}/Pandoc
  $ENV{LOCALAPPDATA}/Pandoc/bin
  $ENV{LOCALAPPDATA}/Pandoc
  DOC
  "a universal document converter"
  )

if(Pandoc)
  execute_process(COMMAND ${Pandoc} --version
    OUTPUT_VARIABLE Pandoc_VERSION
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  if(WIN32)
    string(REGEX REPLACE "^(.*\n)?pandoc.exe ([.0-9]+).*"
      "\\2" Pandoc_VERSION "${Pandoc_VERSION}")
  endif(WIN32)
  string(REGEX REPLACE "^(.*\n)?pandoc ([.0-9]+).*"
    "\\2" Pandoc_VERSION "${Pandoc_VERSION}")
endif(Pandoc)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Pandoc
  REQUIRED_VARS Pandoc
  VERSION_VAR Pandoc_VERSION
  )

mark_as_advanced(Pandoc)
