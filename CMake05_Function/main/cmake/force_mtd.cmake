MACRO(configureMsvcRuntime)
MESSAGE(STATUS "configureMsvcRuntime() called. ")
    IF(WIN32)
        # Default to statically-linked runtime.
        IF("${MSVC_RUNTIME}" STREQUAL "")
            SET(MSVC_RUNTIME "static")
        ENDIF()

        # Set compiler options.
        SET(variables
            CMAKE_C_FLAGS_DEBUG
            CMAKE_C_FLAGS_MINSIZEREL
            CMAKE_C_FLAGS_RELEASE
            CMAKE_C_FLAGS_RELWITHDEBINFO
            CMAKE_CXX_FLAGS_DEBUG
            CMAKE_CXX_FLAGS_MINSIZEREL
            CMAKE_CXX_FLAGS_RELEASE
            CMAKE_CXX_FLAGS_RELWITHDEBINFO
        )
        IF(${MSVC_RUNTIME} STREQUAL "static")
            MESSAGE("MSVC -> forcing use of statically-linked runtime.")
            FOREACH(variable ${variables})
                IF(${variable} MATCHES "/MD")
                    STRING(REGEX REPLACE "/MD" "/MT" ${variable} "${${variable}}")
                ENDIF()
                IF(${variable} MATCHES "/MDd")
                    STRING(REGEX REPLACE "/MDd" "/MTd" ${variable} "${${variable}}")
                ENDIF()
            ENDFOREACH()
        ELSE()
            MESSAGE("MSVC -> forcing use of dynamically-linked runtime.")
            FOREACH(variable ${variables})
                IF(${variable} MATCHES "/MT")
                    STRING(REGEX REPLACE "/MT" "/MD" ${variable} "${${variable}}")
                ENDIF()
            ENDFOREACH()
            FOREACH(variable ${variables})
                IF(${variable} MATCHES "/MTd")
                    STRING(REGEX REPLACE "/MTd" "/MDd" ${variable} "${${variable}}")
                ENDIF()
            ENDFOREACH()
        ENDIF()
    ENDIF()
ENDMACRO()