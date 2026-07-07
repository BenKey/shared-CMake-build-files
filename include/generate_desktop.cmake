if(NOT DEFINED APP_NAME OR APP_NAME STREQUAL "")
    message(FATAL_ERROR "APP_NAME is required by generate_desktop.cmake")
endif()

if(IS_ABSOLUTE "${CMAKE_INSTALL_BINDIR}")
    set(_desktop_bindir "${CMAKE_INSTALL_BINDIR}")
else()
    set(_desktop_bindir "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}")
endif()
if(IS_ABSOLUTE "${CMAKE_INSTALL_DATAROOTDIR}")
    set(_desktop_datarootdir "${CMAKE_INSTALL_DATAROOTDIR}")
else()
    set(_desktop_datarootdir "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}")
endif()

set(_desktop_exec "${_desktop_bindir}/${APP_NAME}")
set(_desktop_icon "${_desktop_datarootdir}/icons/hicolor/48x48/apps/${APP_NAME}.png")

# Configure-time mode: write desktop file into build tree.
if(DEFINED DESKTOP_OUTPUT_FILE AND NOT DESKTOP_OUTPUT_FILE STREQUAL "")
    get_filename_component(_desktop_dir "${DESKTOP_OUTPUT_FILE}" DIRECTORY)
    file(MAKE_DIRECTORY "${_desktop_dir}")
    file(WRITE "${DESKTOP_OUTPUT_FILE}"
    "[Desktop Entry]\n"
    "Type=Application\n"
    "Name=${APP_NAME}\n"
    "Exec=${_desktop_exec}\n"
    "Icon=${_desktop_icon}\n"
    "Terminal=false\n"
    "Categories=Utility;\n"
    )
    return()
endif()

# Install-time rewrite mode: update an already-installed desktop file with
# absolute paths derived from the install-time prefix.
if(DEFINED DESKTOP_REWRITE_INSTALLED_FILE AND NOT DESKTOP_REWRITE_INSTALLED_FILE STREQUAL "")
    if(DEFINED DESKTOP_REWRITE_BINDIR AND NOT DESKTOP_REWRITE_BINDIR STREQUAL "")
        set(_rewrite_bindir "${DESKTOP_REWRITE_BINDIR}")
    elseif(DEFINED CMAKE_INSTALL_BINDIR AND NOT CMAKE_INSTALL_BINDIR STREQUAL "")
        set(_rewrite_bindir "${CMAKE_INSTALL_BINDIR}")
    else()
        set(_rewrite_bindir "bin")
    endif()

    if(DEFINED DESKTOP_REWRITE_DATAROOTDIR AND NOT DESKTOP_REWRITE_DATAROOTDIR STREQUAL "")
        set(_rewrite_datarootdir "${DESKTOP_REWRITE_DATAROOTDIR}")
    elseif(DEFINED CMAKE_INSTALL_DATAROOTDIR AND NOT CMAKE_INSTALL_DATAROOTDIR STREQUAL "")
        set(_rewrite_datarootdir "${CMAKE_INSTALL_DATAROOTDIR}")
    else()
        set(_rewrite_datarootdir "share")
    endif()

    if(IS_ABSOLUTE "${_rewrite_bindir}")
        set(_abs_bindir "${_rewrite_bindir}")
    else()
        set(_abs_bindir "${CMAKE_INSTALL_PREFIX}/${_rewrite_bindir}")
    endif()

    if(IS_ABSOLUTE "${_rewrite_datarootdir}")
        set(_abs_datarootdir "${_rewrite_datarootdir}")
    else()
        set(_abs_datarootdir "${CMAKE_INSTALL_PREFIX}/${_rewrite_datarootdir}")
    endif()

    set(_abs_exec "${_abs_bindir}/${APP_NAME}")
    set(_abs_icon "${_abs_datarootdir}/icons/hicolor/48x48/apps/${APP_NAME}.png")
    if(IS_ABSOLUTE "${DESKTOP_REWRITE_INSTALLED_FILE}")
        set(_rewrite_file "${DESKTOP_REWRITE_INSTALLED_FILE}")
    else()
        set(_rewrite_file "${CMAKE_INSTALL_PREFIX}/${DESKTOP_REWRITE_INSTALLED_FILE}")
    endif()

    # Prevent accidental literal directory creation like ${CMAKE_INSTALL_DATAROOTDIR}.
    if(_rewrite_file MATCHES "\\$\\{[^}]+\\}")
        message(FATAL_ERROR
            "DESKTOP_REWRITE_INSTALLED_FILE contains unresolved variable tokens: '${_rewrite_file}'. "
            "Pass a concrete path (typically configure-time CMAKE_INSTALL_DATAROOTDIR + '/applications/<app>.desktop')."
        )
    endif()

    get_filename_component(_rewrite_dir "${_rewrite_file}" DIRECTORY)
    file(MAKE_DIRECTORY "${_rewrite_dir}")
    file(WRITE "${_rewrite_file}"
    "[Desktop Entry]\n"
    "Type=Application\n"
    "Name=${APP_NAME}\n"
    "Exec=${_abs_exec}\n"
    "Icon=${_abs_icon}\n"
    "Terminal=false\n"
    "Categories=Utility;\n"
    )
    return()
endif()

# Install-script mode: keep compatibility with existing callers.
set(_install_root "${CMAKE_INSTALL_PREFIX}")
set(_desktop_dir "${_install_root}/share/applications")
set(_icon_dir "${_install_root}/share/icons/hicolor")
set(_desktop_file "${_desktop_dir}/${APP_NAME}.desktop")

file(MAKE_DIRECTORY "${_desktop_dir}")
file(WRITE "${_desktop_file}"
"[Desktop Entry]
Type=Application
Name=${APP_NAME}
Exec=${_desktop_exec}
Icon=${_desktop_icon}
Terminal=false
Categories=Utility;
")

find_program(GTK_UPDATE_ICON_CACHE NAMES gtk-update-icon-cache)
if(GTK_UPDATE_ICON_CACHE)
    message(STATUS "Updating the icon cache.")
    execute_process(
        COMMAND ${GTK_UPDATE_ICON_CACHE} -f -t "${_icon_dir}"
        ERROR_QUIET
    )
endif()

find_program(UPDATE_DESKTOP_DATABASE NAMES update-desktop-database)
if(UPDATE_DESKTOP_DATABASE)
    message(STATUS "Updating the desktop database.")
    execute_process(
        COMMAND ${UPDATE_DESKTOP_DATABASE} "${_desktop_dir}"
        ERROR_QUIET
    )
endif()
