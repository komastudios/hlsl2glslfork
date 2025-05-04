function(target_extract_symbols
        LIBRARY_TARGET     # The static library target to extract symbols from
        OUTPUT_FILE        # Path where to save the extracted symbols
        PYTHON_SCRIPT_DIR) # Directory containing the extract_symbols.py script

    # Find Python
    find_package(Python3 COMPONENTS Interpreter REQUIRED)

    # Get the absolute path to the script
    set(EXTRACT_SCRIPT "${PYTHON_SCRIPT_DIR}/extract_symbols.py")
    if(NOT EXISTS "${EXTRACT_SCRIPT}")
        message(FATAL_ERROR "extract_symbols.py not found in ${PYTHON_SCRIPT_DIR}")
    endif()

    set(EXTRACT_OPTIONS --ignore-cpp)

    # Create the output directory if it doesn't exist
    get_filename_component(OUTPUT_DIR "${OUTPUT_FILE}" DIRECTORY)
    file(MAKE_DIRECTORY "${OUTPUT_DIR}")

    # Add custom command to extract symbols
    add_custom_command(
            OUTPUT "${OUTPUT_FILE}"
            #COMMAND ${Python3_EXECUTABLE}
            COMMAND pdm run
            "${EXTRACT_SCRIPT}"
            ${EXTRACT_OPTIONS}
            $<TARGET_FILE:${LIBRARY_TARGET}>
            "${OUTPUT_FILE}"
            DEPENDS ${LIBRARY_TARGET} "${EXTRACT_SCRIPT}"
            COMMENT "Extracting symbols from ${LIBRARY_TARGET}"
            VERBATIM
    )

    # Add custom target that depends on the symbol extraction
    add_custom_target(
            ${LIBRARY_TARGET}_extract_symbols
            DEPENDS "${OUTPUT_FILE}"
    )

    # Make the symbol extraction target depend on the library target
    add_dependencies(${LIBRARY_TARGET}_extract_symbols ${LIBRARY_TARGET})

endfunction()
