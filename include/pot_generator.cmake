find_program(XGETTEXT_EXECUTABLE xgettext)

function(create_pot_target TARGET_NAME SOURCES)
    if(NOT XGETTEXT_EXECUTABLE)
        message(STATUS "xgettext not found; target ${TARGET_NAME} will not be created.")
        return()
    endif()
    if(NOT TARGET_NAME)
        message(FATAL_ERROR "TARGET_NAME argument is required for create_pot_target.")
    endif()
    if (NOT PROJECT_NAME)
        message(FATAL_ERROR "PROJECT_NAME variable must be set before calling create_pot_target.")
    endif()
    if(NOT COPYRIGHT_HOLDER)
        message(STATUS "COPYRIGHT_HOLDER not set; using default value.")
        set(COPYRIGHT_HOLDER "Benilda Key")
    endif()
    if(NOT PRODUCT_VERSION)
        message(STATUS "PRODUCT_VERSION not set; using default value.")
        set(PRODUCT_VERSION "1.0.0")
    endif()
    if(NOT PRODUCT_EMAIL_ADDRESS)
        message(STATUS "PRODUCT_EMAIL_ADDRESS not set; using default value.")
        set(PRODUCT_EMAIL_ADDRESS "benilda.key@yekneb.com")
    endif()
    if(NOT SOURCES)
        message(STATUS "No sources provided; target ${TARGET_NAME} will not be created.")
        return()
    endif()
    add_custom_target(
        ${TARGET_NAME}
        COMMAND ${XGETTEXT_EXECUTABLE}
        --copyright-holder="${COPYRIGHT_HOLDER}"
        --package-name="${PROJECT_NAME}"
        --package-version="${PRODUCT_VERSION}"
        --msgid-bugs-address="${PRODUCT_EMAIL_ADDRESS}"
        --output=${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}.pot
        --keyword=_
        --keyword=boost::locale::translate:1,1t
        --keyword=boost::locale::translate:1,2,3t
        --keyword=gettext:1
        --keyword=N_
        --keyword=ngettext:1,2
        --keyword=npgettext:1c,2,3
        --keyword=pgettext:1c,2
        --keyword=translate:1,1t
        --keyword=translate:1,2,3t
        --keyword=translate:1c,2,2t
        --keyword=translate:1c,2,3,4t
        --boost
        --from-code=UTF-8
        --no-location
        ${SOURCES}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Generating POT file for ${PROJECT_NAME} v${PRODUCT_VERSION}"
    )
endfunction()
