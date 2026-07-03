set(EXEC_PATH "${CMAKE_INSTALL_PREFIX}/bin/${APP_NAME}")
set(ICON_PATH "${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/48x48/apps/${APP_NAME}.png")
file(WRITE "${CMAKE_INSTALL_PREFIX}/share/applications/${APP_NAME}.desktop"
"[Desktop Entry]
Type=Application
Name=${APP_NAME}
Exec=${EXEC_PATH}
Icon=${ICON_PATH}
Terminal=false
Categories=Utility;
")
find_program(GTK_UPDATE_ICON_CACHE NAMES gtk-update-icon-cache)
if(GTK_UPDATE_ICON_CACHE)
    message(STATUS "Updating the icon cache.")
    execute_process(
        COMMAND ${GTK_UPDATE_ICON_CACHE} -f -t "${CMAKE_INSTALL_PREFIX}/share/icons/hicolor"
        ERROR_QUIET
    )
endif()
find_program(UPDATE_DESKTOP_DATABASE NAMES update-desktop-database)
if(UPDATE_DESKTOP_DATABASE)
    message(STATUS "Updating the desktop database.")
    execute_process(
        COMMAND ${UPDATE_DESKTOP_DATABASE} "${CMAKE_INSTALL_PREFIX}/share/applications"
        ERROR_QUIET
    )
endif()
