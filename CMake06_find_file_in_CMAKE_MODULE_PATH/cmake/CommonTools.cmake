# ============================================================================
# Copyright (c) 2020, Bizerba SE & Co. KG, Harald Stingel, ESS-DA/IN: Infrastructure
# All rights reserved.
#
# ============================================================================

# ============================================================================
# @file  CommonTools.cmake
# @brief Definition of common CMake functions.
#
# @ingroup CMakeTools
# ============================================================================

# ----------------------------------------------------------------------------
include_guard()

# ============================================================================
# generator expressions
# ============================================================================

## @brief Name of build configuration ("$<CONFIG>") generator expression
if( CMAKE_MAJOR_VERSION LESS 3 )
	set( BASIS_GE_CONFIG "CONFIGURATION" )
else()
	set( BASIS_GE_CONFIG "CONFIG" )
endif()

# ============================================================================
# variable_value_status
# ============================================================================

## @brief Create a string from a list of variables indicating if they are
#         defined and their values.
#
# Useful for debug and user errors, for example:
# @code
# set( VAR1 "I'm a string" )
# set( VAR2 2 )
# variable_value_status( VAR_INFO_STRING VAR1 VAR2 VAR3 )
# message( STATUS ${VAR_INFO_STRING} )
# @endcode
#
# @param[out] VAR_INFO_STRING The output string variable that will set with the debug string.
# @param[in]  ARGN            List of variables to be put into a string along with their value.

function( variable_value_status VAR_INFO_STRING )
	set( OUTPUT_STRING )
	foreach( VARIABLE_NAME IN ITEMS ${ARGN} )
		# message( STATUS "************* VARIABLE_NAME ${VARIABLE_NAME}" )
		if( DEFINED ${VARIABLE_NAME} )
			set( OUTPUT_STRING "${OUTPUT_STRING}\n   variable name: ${VARIABLE_NAME}  value: ${${VARIABLE_NAME}}" )
		else()
			set( OUTPUT_STRING "${OUTPUT_STRING}\n   variable name: ${VARIABLE_NAME}  value is not defined" )
		endif()
	endforeach()
	set( ${VAR_INFO_STRING} ${OUTPUT_STRING} PARENT_SCOPE )
endfunction()

# ============================================================================
# addRunAndDebugTargets
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Adds -run and -dbg targets.
#
# Helper macro for creating convenient targets.

#
# @param [in] TARGET The custom target to add.

# Helper macro for creating convenient targets
find_program( GDB_PATH gdb )

# Adds -run and -dbg targets.
macro( addRunAndDebugTargets TARGET )
	add_custom_target( ${TARGET}-run
		WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
		USES_TERMINAL
		DEPENDS ${TARGET}
		COMMAND ./${TARGET} )

	# Convenience run gdb target.
	if( GDB_PATH )
		add_custom_target( ${TARGET}-gdb
			WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
			USES_TERMINAL
			DEPENDS ${TARGET}
			COMMAND ${GDB_PATH} ./${TARGET} )
	endif()
endmacro()

# ============================================================================
# ExternalHeaderOnly_Add
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Usefull for adding header only libraries.
#
# This function XXX.

# Example usage:
#
# @code
# ExternalHeaderOnly_Add( "Catch"
#	https://github.com/catchorg/Catch2.git" "master" "single_include/catch2" )
# @endcode
#
# Use with:
#     target_link_libraries( unittests Catch )
# This will add the INCLUDE_FOLDER_PATH to the `unittests` target.
#
# @param [in]  LIBNAME  xxx.
# @param [in]  REPOSITORY  xxx.
# @param [in]  GIT_TAG  xxx.
# @param [in]  INCLUDE_FOLDER_PATH  xxx.

macro( ExternalHeaderOnly_Add LIBNAME REPOSITORY GIT_TAG INCLUDE_FOLDER_PATH )
	ExternalProject_Add(
		${LIBNAME}_download
		PREFIX ${CMAKE_CURRENT_LIST_DIR}/${LIBNAME}
		GIT_REPOSITORY ${REPOSITORY}
		# For shallow git clone (without downloading whole history)
		# GIT_SHALLOW 1
		# For point at certain tag
		GIT_TAG origin/${GIT_TAG}
		# disables auto update on every build
		UPDATE_DISCONNECTED 1
		# disable following
		CONFIGURE_COMMAND "" BUILD_COMMAND "" INSTALL_DIR "" INSTALL_COMMAND ""
		)
	# Special target.
	add_custom_target( ${LIBNAME}_update
		COMMENT "Updated ${LIBNAME}"
		WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${LIBNAME}/src/${LIBNAME}_download
		COMMAND ${GIT_EXECUTABLE} fetch --recurse-submodules
		COMMAND ${GIT_EXECUTABLE} reset --hard origin/${GIT_TAG}
		COMMAND ${GIT_EXECUTABLE} submodule update --init --force --recursive --remote --merge
		DEPENDS ${LIBNAME}_download )

	set( ${LIBNAME}_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/${LIBNAME}/src/${LIBNAME}_download/ )
	add_library( ${LIBNAME} INTERFACE )
	add_dependencies( ${LIBNAME} ${LIBNAME}_download )
	add_dependencies( update ${LIBNAME}_update )
	target_include_directories( ${LIBNAME} SYSTEM INTERFACE ${CMAKE_CURRENT_LIST_DIR}/${LIBNAME}/src/${LIBNAME}_download/${INCLUDE_FOLDER_PATH} )
endmacro()

# ============================================================================
# ExternalDownloadNowGit
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Clone git repo during cmake setup phase, also adds target.
#
# This command will clone git repo during cmake setup phase, also adds the
# ${LIBNAME}_update target into general update target.

# Example usage:
#
# @code
# ExternalDownloadNowGit( cpr https://github.com/finkandreas/cpr.git origin/master )
# add_subdirectory( ${cpr_SOURCE_DIR} )
# @endcode
#
# @param [in]  LIBNAME  xxx.
# @param [in]  REPOSITORY  xxx.
# @param [in]  GIT_TAG  xxx.

macro( ExternalDownloadNowGit LIBNAME REPOSITORY GIT_TAG )
	set( ${LIBNAME}_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/${LIBNAME}/src/${LIBNAME}_download/ )

	# Clone repository if not done.
	if( IS_DIRECTORY ${${LIBNAME}_SOURCE_DIR} )
		message( STATUS "Already downloaded: ${REPOSITORY}" )
	else()
		message( STATUS "Clonning: ${REPOSITORY}" )
		execute_process(
			WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
			COMMAND ${GIT_EXECUTABLE} clone --recursive ${REPOSITORY} ${LIBNAME}/src/${LIBNAME}_download
			)
		# Switch to target TAG and update submodules.
		execute_process(
			WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${LIBNAME}/src/${LIBNAME}_download
			COMMAND ${GIT_EXECUTABLE} reset --hard origin/${GIT_TAG}
			COMMAND ${GIT_EXECUTABLE} submodule update --init --force --recursive --remote --merge
			)
	endif()

	# Special update target.
	add_custom_target( ${LIBNAME}_update
		COMMENT "Updated ${LIBNAME}"
		WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${LIBNAME}/src/${LIBNAME}_download
		COMMAND ${GIT_EXECUTABLE} fetch --recurse-submodules
		COMMAND ${GIT_EXECUTABLE} reset --hard origin/${GIT_TAG}
		COMMAND ${GIT_EXECUTABLE} submodule update --init --force --recursive --remote --merge )
	# Add this as dependency to the general update target.
	add_dependencies( update ${LIBNAME}_update )
endmacro()

# ============================================================================
# addMiscTargets
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Add Other MISC targets - formating, static analysis  format, cppcheck, tidy.
#
# This macro adds other MISC targets - formating, static analysis  format, cppcheck, tidy.
#
# @param [out] REGEX xxx.
# @param [in]  ARGN  xxx.

macro( addMiscTargets )
	file( GLOB_RECURSE ALL_SOURCE_FILES *.cpp *.cc *.c )
	file( GLOB_RECURSE ALL_HEADER_FILES *.h *.hpp )

	# Static analysis via clang-tidy target.
	#    We check for program, since when it is not here, target makes no sense.
	find_program( TIDY_PATH clang-tidy PATHS /usr/local/Cellar/llvm/*/bin )
	if( TIDY_PATH )
		message( STATUS "    == clang-tidy - static analysis                    YES " )
		add_custom_target( tidy
			COMMAND ${TIDY_PATH} -header-filter=.* ${ALL_SOURCE_FILES} -p=./ )
	else()
		message( STATUS "    == clang-tidy - static analysis                    NO " )
	endif()

	# cpp check static analysis.
	find_program( CPPCHECK_PATH cppcheck )
	if( CPPCHECK_PATH )
		message( STATUS "    == cppcheck - static analysis                      YES " )
		add_custom_target(
				cppcheck
				COMMAND ${CPPCHECK_PATH}
				--enable=warning,performance,portability,information,missingInclude
				--std=c++11
				--template=gcc
				--verbose
				--quiet
				${ALL_SOURCE_FILES}
		)
	else()
		message( STATUS "    == cppcheck - static analysis                      NO " )
	endif()

	# Run clang-format on all files.
	find_program( FORMAT_PATH clang-format )
	if( FORMAT_PATH )
		message( STATUS "    == clang-format - code formating                   YES " )
		add_custom_target( format
			COMMAND ${FORMAT_PATH} -i ${ALL_SOURCE_FILES} ${ALL_HEADER_FILES} )
	else()
		message( STATUS "    == clang-format - code formating                   NO " )
	endif()

	# Does not work well, left here for future work, but it would still only
	# provides same info as tidy, only in html form.
	#
	# Produces html analysis in *.plist dirs in build dir or build/source directory
	# add_custom_target(
	#     analyze
	#     COMMAND rm -rf ../*.plist
	#     COMMAND rm -rf *.plist
	#     COMMAND clang-check -analyze -extra-arg -Xclang -extra-arg -analyzer-output=html
	#     ${ALL_SOURCE_FILES}
	#     -p=./
	#     COMMAND echo ""
	#     )
endmacro()

# ============================================================================
# apply_global_cxx_flags_to_all_targets
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Applies CMAKE_CXX_FLAGS to all targets in the current CMake directory.
#
# Applies CMAKE_CXX_FLAGS to all targets in the current CMake directory.
# After this operation, CMAKE_CXX_FLAGS is cleared.
#
# https://stackoverflow.com/questions/28344564/cmake-remove-a-compile-flag-for-a-single-translation-unit
#
# @code
# cmake_minimum_required( VERSION 3.13.4 )
# project( HelloWorld CXX )
# set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2 -Wunused-variable" )
# # CMake will apply this to all targets, so this will work too.
# add_compile_options( "-Werror" )
#
# add_executable( hello-world hello.cpp )
#
# apply_global_cxx_flags_to_all_targets()
# @endcode

macro( apply_global_cxx_flags_to_all_targets )
	separate_arguments( _global_cxx_flags_list UNIX_COMMAND ${CMAKE_CXX_FLAGS} )
	get_property( _targets DIRECTORY PROPERTY BUILDSYSTEM_TARGETS )
	foreach( _target ${_targets} )
		target_compile_options( ${_target} PUBLIC ${_global_cxx_flags_list} )
	endforeach()
	unset( CMAKE_CXX_FLAGS )
	set( _flag_sync_required TRUE )
endmacro()

# ============================================================================
# remove_flag_from_target
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Removes the specified compile flag from the specified target.
#
# Removes the specified compile flag from the specified target.
#
# Pre: apply_global_cxx_flags_to_all_targets() must be invoked.
#
# https://stackoverflow.com/questions/28344564/cmake-remove-a-compile-flag-for-a-single-translation-unit
#
# @code
# cmake_minimum_required( VERSION 3.13.4 )
# project( HelloWorld CXX )
# set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2 -Wunused-variable" )
# # CMake will apply this to all targets, so this will work too.
# set( COMPILE_FLAG_ERROR "-Werror" )
# add_compile_options( "-Werror" )
#
# add_executable( hello-world hello.cpp )
#
# apply_global_cxx_flags_to_all_targets()
# remove_flag_from_target( hello-world "-Werror" )
# @endcode
#
# @param [in] _target - The target to remove the compile flag from
# @param [in] _flag - The compile flag to remove

macro( remove_flag_from_target _target _flag )
	get_target_property( _target_cxx_flags ${_target} COMPILE_OPTIONS )
	if( _target_cxx_flags )
		list( REMOVE_ITEM _target_cxx_flags ${_flag} )
		set_target_properties( ${_target} PROPERTIES COMPILE_OPTIONS "${_target_cxx_flags}" )
	endif()
endmacro()

# ============================================================================
# remove_flag_from_file
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Removes the specified compiler flag from the specified file.
#
# Removes the specified compiler flag from the specified file.
#
# Pre: apply_global_cxx_flags_to_all_targets() must be invoked.
#
# https://stackoverflow.com/questions/28344564/cmake-remove-a-compile-flag-for-a-single-translation-unit
#
# @code
# cmake_minimum_required( VERSION 3.13.4 )
# project( HelloWorld CXX )
# set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2 -Wunused-variable" )
# # CMake will apply this to all targets, so this will work too.
# set( COMPILE_FLAG_ERROR "-Werror" )
# add_compile_options( "-Werror" )
#
# add_executable( hello-world hello.cpp )
#
# apply_global_cxx_flags_to_all_targets()
# remove_flag_from_target( hello-world "-Werror" )
# @endcode
#
# @param [in] _target - The target that _file belongs to
# @param [in] _file - The file to remove the compiler flag from
# @param [in] _flag - The compiler flag to remove.

macro( remove_flag_from_file _target _file _flag )
	get_target_property( _target_sources ${_target} SOURCES )
	# Check if a sync is required, in which case we'll force a rewrite of the cache variables.
	if( _flag_sync_required )
		unset( _cached_${_target}_cxx_flags CACHE )
		unset( _cached_${_target}_${_file}_cxx_flags CACHE )
	endif()
	get_target_property( _${_target}_cxx_flags ${_target} COMPILE_OPTIONS )
	# On first entry, cache the target compile flags and apply them to each source file
	# in the target.
	if( NOT _cached_${_target}_cxx_flags )
		# Obtain and cache the target compiler options, then clear them.
		get_target_property( _target_cxx_flags ${_target} COMPILE_OPTIONS )
		set( _cached_${_target}_cxx_flags "${_target_cxx_flags}" CACHE INTERNAL "" )
		set_target_properties( ${_target} PROPERTIES COMPILE_OPTIONS "" )
		# Apply the target compile flags to each source file.
		foreach( _source_file ${_target_sources} )
			# Check for pre-existing flags set by set_source_files_properties().
			get_source_file_property( _source_file_cxx_flags ${_source_file} COMPILE_FLAGS )
			if( _source_file_cxx_flags )
				separate_arguments( _source_file_cxx_flags UNIX_COMMAND ${_source_file_cxx_flags} )
				list( APPEND _source_file_cxx_flags "${_target_cxx_flags}" )
			else()
				set( _source_file_cxx_flags "${_target_cxx_flags}" )
			endif()
			# Apply the compile flags to the current source file.
			string( REPLACE ";" " " _source_file_cxx_flags_string "${_source_file_cxx_flags}" )
			set_source_files_properties( ${_source_file} PROPERTIES COMPILE_FLAGS "${_source_file_cxx_flags_string}" )
		endforeach()
	endif()
	list( FIND _target_sources ${_file} _file_found_at )
	if( _file_found_at GREATER -1 )
		if( NOT _cached_${_target}_${_file}_cxx_flags )
			# Cache the compile flags for the specified file.
			# This is the list that we'll be removing flags from.
			get_source_file_property( _source_file_cxx_flags ${_file} COMPILE_FLAGS )
			separate_arguments( _source_file_cxx_flags UNIX_COMMAND ${_source_file_cxx_flags} )
			set( _cached_${_target}_${_file}_cxx_flags ${_source_file_cxx_flags} CACHE INTERNAL "" )
		endif()
		# Remove the specified flag, then re-apply the rest.
		list( REMOVE_ITEM _cached_${_target}_${_file}_cxx_flags ${_flag} )
		string( REPLACE ";" " " _cached_${_target}_${_file}_cxx_flags_string "${_cached_${_target}_${_file}_cxx_flags}" )
		set_source_files_properties( ${_file} PROPERTIES COMPILE_FLAGS "${_cached_${_target}_${_file}_cxx_flags_string}" )
	endif()
endmacro()

# ============================================================================
# normalize_name
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Convert string to lowercase only or mixed case.
#
# Strings in all uppercase or all lowercase are converted to all lowercase
# letters because these are usually used for acronymns. All other strings
# are returned unmodified with the one exception that the first letter has
# to be uppercase for mixed case strings.
#
# This function is in particular used to normalize the project name for use
# in installation directory paths and namespaces.
#
# @code
# set( VAR1 "mixedCase" )
# normalize_name( StrOut ${VAR1} )
# message( Status "${StrOut}" )
# @endcode
#
# @param [out] OUT String in CamelCase.
# @param [in]  STR String.

function( normalize_name OUT STR )
	# Strings in all uppercase or all lowercase such as acronymns are an
	# exception and shall be converted to all lowercase instead.
	string( TOLOWER "${STR}" L )
	string( TOUPPER "${STR}" U )
	if( "${STR}" STREQUAL "${L}" OR "${STR}" STREQUAL "${U}" )
		set( ${OUT} "${L}" PARENT_SCOPE )
		# Change first letter to uppercase.
	else()
		string( SUBSTRING "${U}"   0  1 A )
		string( SUBSTRING "${STR}" 1 -1 B )
		set( ${OUT} "${A}${B}" PARENT_SCOPE )
	endif()
endfunction()

# ============================================================================
# version_numbers
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Extract version numbers from version string.
#
# @param [in]  VERSION Version string in the format "MAJOR[.MINOR[.PATCH]]".
# @param [out] MAJOR   Major version number if given or 0.
# @param [out] MINOR   Minor version number if given or 0.
# @param [out] PATCH   Patch number if given or 0.
#
# @returns See @c [out] parameters.

function( version_numbers VERSION MAJOR MINOR PATCH )
	##	if( VERSION MATCHES "([0-9]+)(\\.[0-9]+)?(\\.[0-9]+)?(rc[1-9][0-9]*|[a-z]+)?" )
	set( VERSION_REGEX "^(([0-9]+)|(rc[1-9][0-9]+))\\.([0-9]+)\\.([0-9]+)$" )
	if( VERSION MATCHES ${VERSION_REGEX} )
		# variable_value_status( VAR_INFO_STRING CMAKE_MATCH_1 CMAKE_MATCH_2 CMAKE_MATCH_3 CMAKE_MATCH_4 )
		# message( STATUS ${VAR_INFO_STRING} )
		string( REGEX MATCHALL "[0-9]+|-([A-Za-z0-9_]+)" VERSION_PARTS ${VERSION} )
		list( GET VERSION_PARTS 0 VERSION_MAJOR )
		list( GET VERSION_PARTS 1 VERSION_MINOR )
		list( GET VERSION_PARTS 2 VERSION_PATCH )
	else()
		set( VERSION_MAJOR 0 )
		set( VERSION_MINOR 0 )
		set( VERSION_PATCH 0 )
	endif()
	set( "${MAJOR}" "${VERSION_MAJOR}" PARENT_SCOPE )
	set( "${MINOR}" "${VERSION_MINOR}" PARENT_SCOPE )
	set( "${PATCH}" "${VERSION_PATCH}" PARENT_SCOPE )
endfunction()

# ============================================================================
# is_cached
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Determine if cache entry exists.
#
# @param [out] VAR   Name of boolean result variable.
# @param [in]  ENTRY Name of cache entry.

macro( is_cached VAR ENTRY )
	if( DEFINED ${ENTRY} )
		get_property( ${VAR} CACHE ${ENTRY} PROPERTY TYPE SET )
	else()
		set( ${VAR} FALSE )
	endif()
endmacro()

# ============================================================================
# set_or_update_type
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Set type of variable.
#
# If the variable is cached, the type is updated, otherwise, a cache entry
# of the given type with the current value of the variable is added.
#
# @param [in] VAR  Name of variable.
# @param [in] TYPE Desired type of variable.
# @param [in] ARGN Optional DOC string used if variable was not cached before.

macro( set_or_update_type VAR TYPE )
	is_cached( _CACHED ${VAR} )
	if( _CACHED )
		set_property( CACHE ${VAR} PROPERTY TYPE ${TYPE} )
	else()
		set( ${VAR} "${${VAR}}" CACHE ${TYPE} "${ARGN}" FORCE )
	endif()
	unset( _CACHED )
endmacro()

# ============================================================================
# set_or_update_value
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Set variable value.
#
# If the variable is cached, this function will update the cache value,
# otherwise, it simply sets the CMake variable uncached to the given value(s).

macro( set_or_update_value VAR )
	is_cached( _CACHED ${VAR} )
	if( _CACHED )
		if( ARGC GREATER 1 )
			set_property( CACHE ${VAR} PROPERTY VALUE ${ARGN} )
		else()
			set( ${VAR} "" CACHE INTERNAL "" FORCE )
		endif()
	else()
		set( ${VAR} ${ARGN} )
	endif()
	unset( _CACHED )
endmacro()

# ============================================================================
# target_public_headers
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Add file(s) to the PUBLIC_HEADER property of a target.
#
# Add one or more files to the PUBLIC_HEADER property of a given target.

# @param [in] TARGET	The given target.
# @param [in] ARGN		The file(s) to add.

macro( target_public_headers TARGET )
	set_target_properties( ${TARGET} PROPERTIES PUBLIC_HEADER "${ARGN}" )
endmacro()

# ============================================================================
# update_value
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Update cache variable.

macro( update_value VAR )
	is_cached( _CACHED ${VAR} )
	if( _CACHED )
		set_property( CACHE ${VAR} PROPERTY VALUE ${ARGN} )
	endif()
	unset( _CACHED )
endmacro()

# ============================================================================
# set_if_empty
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Set value of variable only if variable is not set already.
#
# @param [out] VAR  Name of variable.
# @param [in]  ARGN Arguments to set() command excluding variable name.
#
# @returns Sets @p VAR if its value was not valid before.

macro( set_if_empty VAR )
	if( NOT ${VAR} )
		set( ${VAR} ${ARGN} )
	endif()
endmacro()

# ============================================================================
# set_if_not_set
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Set value of variable only if variable is not defined yet.
#
# @param [out] VAR  Name of variable.
# @param [in]  ARGN Arguments to set() command excluding variable name.
#
# @returns Sets @p VAR if it was not defined before.

macro( set_if_not_set VAR )
	if( NOT DEFINED "${VAR}" )
		set( "${VAR}" ${ARGN} )
	endif()
endmacro()

# ============================================================================
# set_config_option
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Set value of variable to either 0 or 1 based on option value.
#
# This function can be used to convert option values from TRUE/ON to 1 and
# FALSE/OFF to 0 such that they can be used to configure a config.h.in header.
#
# @param [out] VAR Name of configuration header variable.
# @param [in]  OPT Value of CMake option.

macro( set_config_option VAR OPT )
	if( ${OPT} )
		set( "${VAR}" 1 )
	else()
		set( "${VAR}" 0 )
	endif()
endmacro()

# ============================================================================
# list_to_regex
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Convert list into regular expression.
#
# This function is in particular used to convert a list of property names
# such as &lt;CONFIG&gt;_OUTPUT_NAME into a regular expression which can
# be used in pattern matches.
#
# @param [out] REGEX Name of variable for resulting regular expression.
# @param [in]  ARGN  List of patterns which may contain placeholders in the
#                    form of "<this is a placeholder>". These are replaced
#                    by the regular expression "[^ ]+".

macro( list_to_regex REGEX )
	string( REGEX REPLACE "<[^>]+>" "[^ ]+" ${REGEX} "${ARGN}" )
	string( REGEX REPLACE ";" "|" ${REGEX} "${${REGEX}}" )
	set( ${REGEX} "^(${${REGEX}})$" )
endmacro()

# ============================================================================
# FORCE_C_COMPILER
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Force C compiler.
#
# Force compilers, this was deprecated in CMake, but still comes handy sometimes.
#
# @param [in] compiler The compiler.
# @param [in] id       The compiler id.

macro( FORCE_C_COMPILER compiler id )
	set( CMAKE_C_COMPILER "${compiler}" )
	set( CMAKE_C_COMPILER_ID_RUN TRUE )
	set( CMAKE_C_COMPILER_ID ${id} )
	set( CMAKE_C_COMPILER_FORCED TRUE )

	# Set old compiler id variables.
	if( CMAKE_C_COMPILER_ID MATCHES "GNU" )
		set( CMAKE_COMPILER_IS_GNUCC 1 )
	endif()
endmacro()

# ============================================================================
# FORCE_CXX_COMPILER
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Force CXX compiler.
#
# Force compilers, this was deprecated in CMake, but still comes handy sometimes.
#
# @param [in] compiler The compiler.
# @param [in] id       The compiler id.

macro( FORCE_CXX_COMPILER compiler id )
	set( CMAKE_CXX_COMPILER "${compiler}" )
	set( CMAKE_CXX_COMPILER_ID_RUN TRUE )
	set( CMAKE_CXX_COMPILER_ID ${id} )
	set( CMAKE_CXX_COMPILER_FORCED TRUE )

	# Set old compiler id variables.
	if( "${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU" )
		set( CMAKE_COMPILER_IS_GNUCXX 1 )
	endif()
endmacro()

# ============================================================================
# dump_variables
# ============================================================================

## @brief Output current CMake variables to file.

function( dump_variables RESULT_FILE )
	set( DUMP )
	get_cmake_property( VARIABLE_NAMES VARIABLES )
	foreach( V IN LISTS VARIABLE_NAMES )
		if( NOT V MATCHES "^_|^RESULT_FILE$|^ARGC$|^ARGV[0-9]?$|^ARGN_" )
			set( VALUE "${${V}}" )
			# Sanitize value for use in set() command.
			string( REPLACE "\\" "\\\\" VALUE "${VALUE}" )		# Escape backspaces.
			string( REPLACE "\"" "\\\"" VALUE "${VALUE}" )		# Escape double quotes.
			# Escape ${VAR} by \${VAR} such that CMake does not evaluate it.
			# Escape $STR{VAR} by \$STR{VAR} such that CMake does not report a
			# syntax error b/c it expects either ${VAR}, $ENV{VAR}, or $CACHE{VAR}.
			# Escape @VAR@ by \@VAR\@ such that CMake does not evaluate it.
			string( REGEX REPLACE "([^\\])\\\$([^ ]*){" "\\1\\\\\$\\2{" VALUE "${VALUE}" )
			string( REGEX REPLACE "([^\\])\\\@([^ ]*)\@" "\\1\\\\\@\\2\\\\\@" VALUE "${VALUE}" )
			# Append variable to output file.
			set( DUMP "${DUMP}set( ${V} \"${VALUE}\" )\n" )
		endif()
	endforeach()
	file( WRITE "${RESULT_FILE}" "# CMake variables dump created by dump_variables\n${DUMP}" )
endfunction()

# ============================================================================
# write_list
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Write CMake script file which sets the named variable to the
#         specified (list of) values.

function( write_list FILENAME VARIABLE )
	file( WRITE "${FILENAME}" "# Automatically generated. Do not edit this file!\nset (${VARIABLE}\n" )
	foreach( V IN LISTS ARGN )
		file( APPEND "${FILENAME}" "  \"${V}\"\n" )
	endforeach()
	file( APPEND "${FILENAME}" ")\n" )
endfunction()

# ============================================================================
# get_project_property
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Get project-global property value.
#
# Example:
# @code
# get_project_property( TARGETS )
# get_project_property( TARGETS ${PROJECT_NAME} )
# get_project_property( TARGETS ${PROJECT_NAME} TARGETS )
# get_project_property( TARGETS PROPERTY TARGETS )
# @endcode
#
# @param [out] VARIABLE Name of result variable.
# @param [in]  ARGN     See the example uses. The optional second argument
#                       is either the name of the project similar to CMake's
#                       get_target_property() command or the keyword PROPERTY
#                       followed by the name of the property.

function( get_project_property VARIABLE )
	if( ARGC GREATER 3 )
		message( FATAL_ERROR "Too many arguments!" )
	endif()
	if( ARGC EQUAL 1 )
		set( ARGN_PROJECT "${PROJECT_NAME}" )
		set( ARGN_PROPERTY "${VARIABLE}" )
	elseif( ARGC EQUAL 2 )
		if( ARGV1 MATCHES "^PROPERTY$" )
			message( FATAL_ERROR "Expected argument after PROPERTY keyword!" )
		endif()
		set( ARGN_PROJECT  "${ARGV1}" )
		set( ARGN_PROPERTY "${VARIABLE}" )
	else()
		if( ARGV1 MATCHES "^PROPERTY$" )
			set( ARGN_PROJECT "${PROJECT_NAME}" )
		else()
			set( ARGN_PROJECT  "${ARGV1}" )
		endif()
		set( ARGN_PROPERTY "${ARGV2}" )
	endif()
	set( ${VARIABLE} "${${ARGN_PROJECT}_${ARGN_PROPERTY}}" PARENT_SCOPE )
endfunction()

# ============================================================================
# sanitize_for_regex
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Sanitize string variable for use in regular expression.
#
# @note This function may not work for all cases, but is used in particular
#       to sanitize project names, target names, namespace identifiers,...
#
#       This takes all of the dollar signs, and other special characters and
#       adds escape characters such as backslash as necessary.
#
# @param [out] OUT String that can be used in regular expression.
# @param [in]  STR String to sanitize.

macro( sanitize_for_regex OUT STR )
	string( REGEX REPLACE "([.+*?^$])" "\\\\\\1" ${OUT} "${STR}" )
endmacro()

# ============================================================================
# list_to_string
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Concatenates all list elements into a single string.
#
# The list elements are concatenated without any delimiter in between.
# Use list_to_delimited_string() to specify a delimiter such as a
# whitespace character or comma (,) as delimiter.
#
# @param [out] STR  Output string.
# @param [in]  ARGN Input list.
#
# @returns Sets @p STR to the resulting string.
#
# @sa list_to_delimited_string()

function( list_to_string STR )
	set( OUT )
	foreach( ELEM IN LISTS ARGN )
		set( OUT "${OUT}${ELEM}" )
	endforeach()
	set( "${STR}" "${OUT}" PARENT_SCOPE )
endfunction()

# ============================================================================
# list_to_delimited_string
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Concatenates all list elements into a single delimited string.
#
# @param [out] STR   Output string.
# @param [in]  DELIM Delimiter used to separate list elements.
#                    Each element which contains the delimiter as substring
#                    is surrounded by double quotes (") in the output string.
# @param [in]  ARGN  Input list. If this list starts with the argument
#                    @c NOAUTOQUOTE, the automatic quoting of list elements
#                    which contain the delimiter is disabled.
#
# @returns Sets @p STR to the resulting string.
#
# @see join
#
# @todo consider replacing list_to_delimited_string with join

function( list_to_delimited_string STR DELIM )
	set( OUT )
	set( AUTOQUOTE TRUE )
	if( ARGN )
		list( GET ARGN 0 FIRST )
		if( FIRST MATCHES "^NOAUTOQUOTE$" )
			list( REMOVE_AT ARGN 0 )
			set( AUTOQUOTE FALSE )
		endif()
	endif()
	sanitize_for_regex( DELIM_RE "${DELIM}" )
	foreach( ELEM ${ARGN} )
		if( OUT )
			set( OUT "${OUT}${DELIM}" )
		endif()
		if( AUTOQUOTE AND ELEM MATCHES "${DELIM_RE}" )
			set( OUT "${OUT}\"${ELEM}\"" )
		else()
			set( OUT "${OUT}${ELEM}" )
		endif()
	endforeach()
	set( "${STR}" "${OUT}" PARENT_SCOPE )
endfunction()

# ============================================================================
# join
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Concatenates all list elements into a single delimited string.
#
# @param [in]  VALUES       Input list string.
# @param [in]  DELIMITER    Delimiter glue used to separate list elements.
#                           Each element which contains the delimiter as substring
#                           is surrounded by double quotes (") in the output string.
# @param [out] OUTPUT       Output string variable name.
#
# @code
#   set( letters "" "\;a" b c "d\;d" )
#   join( "${letters}" ":" output )
#   message( "${output}" )	# :;a:b:c:d;d
# @endcode
#
# @returns Sets @p OUTPUT to the resulting string.
#
# @see list_to_delimited_string

function( join VALUES DELIMITER OUTPUT )
	set( _TMP_VAL )
	foreach( elem ${VALUES} )
		set( _Val ${elem} )
		if( _Val MATCHES ".${DELIMITER}." )
			set( _Val "\"${_Val}\"" )
		endif()
		# variable_value_status( VAR_INFO_STRING _Val )
		# message( STATUS "${VAR_INFO_STRING}" )
		list( APPEND _TMP_VAL ${_Val} )
	endforeach()
	# variable_value_status( VAR_INFO_STRING _TMP_VAL )
	# message( STATUS "${VAR_INFO_STRING}" )
	string( REGEX REPLACE "([^\\]|^);" "\\1${DELIMITER}" _TMP_STR "${_TMP_VAL}" )
	string( REGEX REPLACE "[\\](.)" "\\1" _TMP_STR "${_TMP_STR}" )	# Fixes escaping.
	set( ${OUTPUT} "${_TMP_STR}" PARENT_SCOPE )
endfunction()

# ============================================================================
# string_to_list
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Splits a string at space characters into a list.
#
# @todo Probably this can be done in a better way ...
#       Difficulty is, that string( REPLACE ) does always replace all
#       occurrences. Therefore, we need a regular expression which matches
#       the entire string. More sophisticated regular expressions should do
#       a better job, though.
#
# @param [out] LST  Output list.
# @param [in]  STR  Input string.
#
# @returns Sets @p LST to the resulting CMake list.

function( string_to_list LST STR )
	set( TMP "${STR}" )
	set( OUT )
	# 1. Extract elements such as "a string with spaces".
	while( TMP MATCHES "\"[^\"]*\"" )
		string( REGEX REPLACE "^(.*)\"([^\"]*)\"(.*)$" "\\1 \\3" TMP "${TMP}" )
		if( OUT )
			set( OUT "${CMAKE_MATCH_2};${OUT}" )
		else()
			set( OUT "${CMAKE_MATCH_2}" )
		endif()
	endwhile()

	# 2. Extract other elements separated by spaces (excluding first and last).
	while( TMP MATCHES " [^\" ]+ " )
		string( REGEX REPLACE "^(.*) ([^\" ]+) (.*)$" "\\1 \\3" TMP "${TMP}" )
		if( OUT )
			set( OUT "${CMAKE_MATCH_2};${OUT}" )
		else()
			set( OUT "${CMAKE_MATCH_2}" )
		endif()
	endwhile()

	# 3. Extract first and last elements (if not done yet).
	if( TMP MATCHES "^[^\" ]+" )
		if( OUT )
			set( OUT "${CMAKE_MATCH_0};${OUT}" )
		else()
			set( OUT "${CMAKE_MATCH_0}" )
		endif()
	endif()

	if( NOT "${CMAKE_MATCH_0}" STREQUAL "${TMP}" AND TMP MATCHES "[^\" ]+$" )
		if( OUT )
			set( OUT "${OUT};${CMAKE_MATCH_0}" )
		else()
			set( OUT "${CMAKE_MATCH_0}" )
		endif()
	endif()

	# Return resulting list.
	set( ${LST} "${OUT}" PARENT_SCOPE )
endfunction()

# ============================================================================
# compare_lists
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Compare two lists.
#
# @param [out] RESULT Result of comparison.
# @param [in]  LIST1  Name of variable holding the first list.
# @param [in]  LIST2  Name of varaible holding the second list.
#
# @retval 0 The two lists are not identical.
# @retval 1 Both lists have identical elements (not necessarily in the same order).

macro( compare_lists RESULT LIST1 LIST2 )
	set( _L1 "${${LIST1}}" )
	set( _L2 "${${LIST2}}" )
	list( SORT _L1 )
	list( SORT _L2 )
	if( "${_L1}" STREQUAL "${_L2}" )
		set( ${RESULT} TRUE )
	else()
		set( ${RESULT} FALSE )
	endif()
	unset( _L1 )
	unset( _L2 )
endmacro()

# ============================================================================
# get_source_target_name
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Derive target name from source file name.
#
# @param [out] TARGET_NAME Target name.
# @param [in]  SOURCE_FILE Source file.
# @param [in]  ARGN        Third argument to get_filename_component().
#                          If not specified, the given path is only sanitized.
# @code
# set( MyFile "D:/Projects/_CMakeSamples/ModernCMakeSample/MyStudentApp/src/MyStudentApp.cpp" )
# get_source_target_name( TargetName ${MyFile} NAME  )
# @endcode
#
# @returns Target name derived from @p SOURCE_FILE.

function( get_source_target_name TARGET_NAME SOURCE_FILE )
	# Remove ".in" suffix from file name.
	string( REGEX REPLACE "\\.in$" "" OUT "${SOURCE_FILE}" )
	# Get name component.
	if( ARGC GREATER 2 )
		get_filename_component( OUT "${OUT}" ${ARGV2} )
	endif()
	# Replace special characters.
	string( REGEX REPLACE "[./\\]" "_" OUT "${OUT}" )
	# Return.
	set( ${TARGET_NAME} "${OUT}" PARENT_SCOPE )
endfunction()

# ============================================================================
# get_source_language
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Detect programming language of given source code files.
#
# This function determines the programming language in which the given source
# code files are written. If no common programming language could be determined,
# "AMBIGUOUS" is returned. If none of the following programming languages
# could be determined, "UNKNOWN" is returned: CXX (i.e., C++), JAVA, MATLAB,
# PYTHON, JYTHON, PERL, BASH, BATCH.
#
# @param [out] LANGUAGE Detected programming language.
# @param [in]  ARGN     List of source code files.

function( get_source_language LANGUAGE )
	set( LANGUAGE_OUT )
	# Iterate over source files.
	foreach( SOURCE_FILE ${ARGN} )
		# skip generator expressions
		if( NOT SOURCE_FILE MATCHES "^\\$<" )
			get_filename_component( SOURCE_FILE "${SOURCE_FILE}" ABSOLUTE )

			if( IS_DIRECTORY "${SOURCE_FILE}" )

				file( GLOB_RECURSE SOURCE_FILES "${SOURCE_FILE}/*" )
				list( APPEND ARGN ${SOURCE_FILES} )

			else()

				# ------------------------------------------------------------------------
				# Determine language based on extension for those without shebang.
				set( LANG )
				# C++.
				if( SOURCE_FILE MATCHES "\\.(c|cc|cpp|cxx|h|hh|hpp|hxx|txx|inl)(\\.in)?$" )
					set( LANG "CXX" )
				# Java.
				elseif( SOURCE_FILE MATCHES "\\.java(\\.in)?$" )
					set( LANG "JAVA" )
				# MATLAB.
				elseif( SOURCE_FILE MATCHES "\\.m(\\.in)?$" )
					set( LANG "MATLAB" )
				endif()

				# ------------------------------------------------------------------------
				# Determine language from shebang directive.
				#
				# Note that some scripting languages may use identical file name extensions.
				# This is in particular the case for Python and Jython. The only way we
				# can distinguish these two is by looking at the shebang directive.
				if( NOT LANG )

					if( NOT EXISTS "${SOURCE_FILE}" AND EXISTS "${SOURCE_FILE}.in" )
						set( SOURCE_FILE "${SOURCE_FILE}.in" )
					endif()
					if( EXISTS "${SOURCE_FILE}" )
						file( STRINGS "${SOURCE_FILE}" FIRST_LINE LIMIT_COUNT 1 )
						if( FIRST_LINE MATCHES "^#!" )
							if( FIRST_LINE MATCHES "^#! */usr/bin/env +([^ ]+)" )
								set( INTERPRETER "${CMAKE_MATCH_1}" )
							elseif( FIRST_LINE MATCHES "^#! *([^ ]+)" )
								set( INTERPRETER "${CMAKE_MATCH_1}" )
								get_filename_component( INTERPRETER "${INTERPRETER}" NAME )
							else()
								set( INTERPRETER )
							endif()
							if( INTERPRETER MATCHES "^(python|jython|perl|bash)$" )
								string( TOUPPER "${INTERPRETER}" LANG )
							endif()
						endif()
					endif()
				endif()

				# ------------------------------------------------------------------------
				# Determine language from further known extensions.
				if( NOT LANG )
					# Python.
					if( SOURCE_FILE MATCHES "\\.py(\\.in)?$" )
						set( LANG "PYTHON" )
					# Perl.
					elseif( SOURCE_FILE MATCHES "\\.(pl|pm|t)(\\.in)?$" )
						set( LANG "PERL" )
					# BASH.
					elseif( SOURCE_FILE MATCHES "\\.sh(\\.in)?$" )
						set( LANG "BASH" )
					# Batch.
					elseif( SOURCE_FILE MATCHES "\\.bat(\\.in)?$" )
						set( LANG "BATCH" )
					# Unknown.
					else()
						set( LANGUAGE_OUT "UNKNOWN" )
						break()
					endif()
				endif()

				# ------------------------------------------------------------------------
				# Detect ambiguity.
				if( LANGUAGE_OUT AND NOT "^${LANG}$" STREQUAL "^${LANGUAGE_OUT}$" )
					if( LANGUAGE_OUT MATCHES "CXX" AND LANG MATCHES "MATLAB" )
						# MATLAB Compiler can handle this...
					elseif( LANGUAGE_OUT MATCHES "MATLAB" AND LANG MATCHES "CXX" )
						set( LANG "MATLAB" )		# language stays MATLAB.
					elseif( LANGUAGE_OUT MATCHES "PYTHON" AND LANG MATCHES "JYTHON" )
						# Jython can deal with Python scripts/modules.
					elseif( LANGUAGE_OUT MATCHES "JYTHON" AND LANG MATCHES "PYTHON" )
						set( LANG "JYTHON" )		# language stays JYTHON
					else()
						# Ambiguity.
						set( LANGUAGE_OUT "AMBIGUOUS" )
						break()
					endif()
				endif()

				# Update current language.
				set( LANGUAGE_OUT "${LANG}" )
			endif()

		endif()
	endforeach()

	# Return.
	if( LANGUAGE_OUT )
		set( ${LANGUAGE} "${LANGUAGE_OUT}" PARENT_SCOPE )
	else()
		message( FATAL_ERROR "get_source_language called without arguments!" )
	endif()
endfunction()

# ============================================================================
# get_filename_component
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Fixes CMake's
#         <a href="https://cmake.org/cmake/help/latest/command/get_filename_component.html">
#         get_filename_component()</a> command.
#
# The "override and call original with a leading _" is probably not well
# documented anywhere.
#
# When function() or macro() is called to define a new command, if a command
# already exists with that name, the undocumented CMake behavior is to make
# the old command available using the same name except with an underscore
# prepended. This applies whether the old name is for a built-in command, a
# custom function or a macro. If a command is only ever overridden once,
# techniques like in the example above appear to work, but if the command
# is overridden again, then the original command is no longer accessible.
# The prepending of one underscore to “save” the previous command only applies
# to the current name, it is not applied recursively to all previous overrides.
# This has the potential to lead to infinite recursion.

# The get_filename_component() command of CMake returns the entire portion
# after the first period (.) [including the period] as extension. However,
# only the component following the last period (.) [including the period]
# should be considered to be the extension.
#
# @note Consider the use of the get_filename_component() macro as
#       an alias to emphasize that this function is different from CMake's
#       <a href="https://cmake.org/cmake/help/latest/command/get_filename_component.html">
#       get_filename_component()</a> command.
#
# @todo Fix issue http://public.kitware.com/Bug/view.php?id=15743 which
#       affects also get_relative_path.
#
# @param [in,out] ARGN Arguments as accepted by get_filename_component().
#
# @returns Sets the variable named by the first argument to the requested
#          component of the given file path.
#
# @sa https://cmake.org/cmake/help/latest/command/get_filename_component.html
# @sa get_filename_component()

function( get_filename_component )
	if( ARGC LESS 3 )
		message( FATAL_ERROR "get_filename_component(): At least three arguments required!" )
	elseif( ARGC GREATER 5 )
		message( WARNING "get_filename_component(): Too many arguments!" )
	endif()
	list( GET ARGN 0 VAR )
	list( GET ARGN 1 STR )
	list( GET ARGN 2 CMD )
	if( CMD MATCHES "^EXT" )
		_get_filename_component( ${VAR} "${STR}" ${CMD} )
		string( REGEX MATCHALL "\\.[^.]*" PARTS "${${VAR}}" )
		list( LENGTH PARTS LEN )
		if( LEN GREATER 1 )
			math( EXPR LEN "${LEN} - 1" )
			list( GET PARTS ${LEN} ${VAR} )
		endif()
	elseif( CMD MATCHES "NAME_WE" )
		_get_filename_component( ${VAR} "${STR}" NAME )
		string( REGEX REPLACE "\\.[^.]*$" "" ${VAR} ${${VAR}} )
	else()
		_get_filename_component( ${VAR} "${STR}" ${CMD} )
	endif()
	if( ARGC EQUAL 4 )
		if( NOT "^${ARGV3}$" STREQUAL "^CACHE$" )
			message( FATAL_ERROR "get_filename_component(): Invalid fourth argument: ${ARGV3}!" )
		else()
			set( ${VAR} "${${VAR}}" CACHE STRING "" )
		endif()
	else()
		set( ${VAR} "${${VAR}}" PARENT_SCOPE )
	endif()
endfunction()

# ============================================================================
# get_relative_path
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Get path relative to a given base directory.
#
# Unlike the file( RELATIVE_PATH ... ) command of CMake which if @p PATH and
# @p BASE are the same directory returns an empty string, this function
# returns a dot (.) in this case instead.
#
# @param [out] REL  @c PATH relative to @c BASE.
# @param [in]  BASE Path of base directory. If a relative path is given, it
#                   is made absolute using get_filename_component()
#                   with ABSOLUTE as last argument.
# @param [in]  PATH Absolute or relative path. If a relative path is given
#                   it is made absolute using get_filename_component()
#                   with ABSOLUTE as last argument.
#
# @returns Sets the variable named by the first argument to the relative path.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:file
#
# @ingroup CMakeAPI

function( get_relative_path REL BASE PATH )
	if( BASE MATCHES "^$" )
		message( FATAL_ERROR "Empty string given where (absolute) base directory path expected!" )
	endif()
	if( PATH MATCHES "^$" )
		set( PATH "." )
	endif()

	# Attention: http://public.kitware.com/Bug/view.php?id=15743.
	get_filename_component( PATH "${PATH}" ABSOLUTE )
	get_filename_component( BASE "${BASE}" ABSOLUTE )
	if( NOT PATH )
		message( FATAL_ERROR "basis_get_relative_path(): No PATH given!" )
	endif()
	if( NOT BASE )
		message( FATAL_ERROR "basis_get_relative_path(): No BASE given!" )
	endif()
	file( RELATIVE_PATH P "${BASE}" "${PATH}" )
	if( "${P}" STREQUAL "" )
		set( P "." )
	endif()
	set( ${REL} "${P}" PARENT_SCOPE )
endfunction()

# ============================================================================
# configure_sources
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Configure .in source files.
#
# This function configures each source file in the given argument list with
# a .in file name suffix and stores the configured file in the build tree
# with the same relative directory as the template source file itself.
# The first argument names the CMake variable of the list of configured
# source files where each list item is the absolute file path of the
# corresponding (configured) source file.
#
# @param [out] LIST_NAME Name of output list.
# @param [in]  ARGN      These arguments are parsed and the following
#                        options recognized. All remaining arguments are
#                        considered to be source file paths.
# @par
# <table border="0">
#   <tr>
#     @tp @b BINARY_DIRECTORY @endtp
#     <td>Explicitly specify directory in build tree where configured
#         source files should be written to.</td>
#   </tr>
#   <tr>
#     @tp @b KEEP_DOT_IN_SUFFIX @endtp
#     <td>By default, after a source file with the .in extension has been
#         configured, the .in suffix is removed from the file name.
#         This can be omitted by giving this option.</td>
#   </tr>
# </table>
#
# @returns Nothing.

function( configure_sources LIST_NAME )
	# Parse arguments.
	cmake_parse_arguments( ARGN "KEEP_DOT_IN_SUFFIX" "BINARY_DIRECTORY" "" ${ARGN} )

	# Ensure that specified BINARY_DIRECTORY is inside build tree of project.
	if( ARGN_BINARY_DIRECTORY )
		get_filename_component( _binpath "${ARGN_BINARY_DIRECTORY}" ABSOLUTE )
		file( RELATIVE_PATH _relpath "${PROJECT_BINARY_DIR}" "${_binpath}" )
		if( _relpath MATCHES "^\\.\\./" )
			message( FATAL_ERROR "Specified BINARY_DIRECTORY must be inside the build tree!" )
		endif()
		unset( _binpath )
		unset( _relpath )
	endif()

	# Configure source files.
	set( CONFIGURED_SOURCES )

	foreach( SOURCE ${ARGN_UNPARSED_ARGUMENTS} )
		# The .in suffix is optional, add it here if a .in file exists for this
		# source file, but only if the source file itself does not name an actually
		# existing source file.
		#
		# If the source file path is relative, prefer possibly already configured
		# sources in build tree such as the test driver source file created by
		# create_test_sourcelist() or a manual use of configure_file().
		#
		# Note: Make path absolute, otherwise EXISTS check will not work!

		if( NOT IS_ABSOLUTE "${SOURCE}" )
			if( EXISTS "${CMAKE_CURRENT_BINARY_DIR}/${SOURCE}" )
				set( SOURCE "${CMAKE_CURRENT_BINARY_DIR}/${SOURCE}" )
			elseif( EXISTS "${CMAKE_CURRENT_BINARY_DIR}/${SOURCE}.in" )
				set( SOURCE "${CMAKE_CURRENT_BINARY_DIR}/${SOURCE}.in" )
			elseif( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE}" )
				set( SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE}" )
			elseif( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE}.in" )
				set( SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE}.in" )
			endif()
		else()
			if( NOT EXISTS "${SOURCE}" AND EXISTS "${SOURCE}.in" )
				set( SOURCE "${SOURCE}.in" )
			endif()
		endif()

		# Configure source file if filename ends in .in suffix.
		if( SOURCE MATCHES "\\.in$" )
			# If binary directory was given explicitly, use it.
			if( ARGN_BINARY_DIRECTORY )
				get_filename_component( SOURCE_NAME "${SOURCE}" NAME )
				if( NOT ARGN_KEEP_DOT_IN_SUFFIX )
					string( REGEX REPLACE "\\.in$" "" SOURCE_NAME "${SOURCE_NAME}" )
				endif()
				set( CONFIGURED_SOURCE "${ARGN_BINARY_DIRECTORY}/${SOURCE_NAME}" )
			# Otherwise,
			else()
				# If source is in project's source tree use relative binary directory.
				if( "^${SOURCE}$" STREQUAL "^${PROJECT_SOURCE_DIR}$" )
					get_relative_path( CONFIGURED_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}" "${SOURCE}" )
					get_filename_component( CONFIGURED_SOURCE "${CMAKE_CURRENT_BINARY_DIR}/${CONFIGURED_SOURCE}" ABSOLUTE )
					if( NOT ARGN_KEEP_DOT_IN_SUFFIX )
						string( REGEX REPLACE "\\.in$" "" CONFIGURED_SOURCE "${CONFIGURED_SOURCE}" )
					endif()
				# Otherwise, use current binary directory.
				else()
					get_filename_component( SOURCE_NAME "${SOURCE}" NAME )
					if( NOT ARGN_KEEP_DOT_IN_SUFFIX )
						string( REGEX REPLACE "\\.in$" "" SOURCE_NAME "${SOURCE_NAME}" )
					endif()
					set( CONFIGURED_SOURCE "${CMAKE_CURRENT_BINARY_DIR}/${SOURCE_NAME}" )
				endif()
			endif()

			# Configure source file.
			configure_file( "${SOURCE}" "${CONFIGURED_SOURCE}" @ONLY )
			if( _DEBUG )
				message( "** Configured source file with .in extension" )
			endif()

		# Otherwise, skip configuration of this source file.
		else()
			set( CONFIGURED_SOURCE "${SOURCE}" )
			if( _DEBUG )
				message( "** Skipped configuration of source file" )
			endif()
		endif()

		if( _DEBUG )
			message( "**     Source:            ${SOURCE}" )
			message( "**     Configured source: ${CONFIGURED_SOURCE}" )
		endif()

		list( APPEND CONFIGURED_SOURCES "${CONFIGURED_SOURCE}" )
	endforeach()

	# Return.
	set( ${LIST_NAME} "${CONFIGURED_SOURCES}" PARENT_SCOPE )
endfunction()

# ============================================================================
# remove_blank_line
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Remove one blank line from top of string

macro( remove_blank_line STRVAR )
	if( ${STRVAR} MATCHES "(^|(.*)\n)[ \t]*\n(.*)" )
		set( ${STRVAR} "${CMAKE_MATCH_1}${CMAKE_MATCH_3}" )
	endif()
endmacro()

# ============================================================================
# get_target_uid
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Get "global" target name, i.e., actual CMake target name.
#
# The counterpart get_target_name() can be used to convert the target UID
# back to the target name without namespace prefix.
#
# @param [out] TARGET_UID  "Global" target name, i.e., actual CMake target name.
# @param [in]  TARGET_NAME Target name used as argument to CMake functions.
#
# @returns Sets @p TARGET_UID to the UID of the build target @p TARGET_NAME.
#
# @sa get_target_name()

function( get_target_uid TARGET_UID TARGET_NAME )
	if( TARGET_NAME MATCHES "^\\.+(.*)$" )
		set( ${TARGET_UID} "${CMAKE_MATCH_1}" PARENT_SCOPE )
	else()
		set( "${TARGET_UID}" "${TARGET_NAME}" PARENT_SCOPE )
	endif()
endfunction()

# ============================================================================
# _get_target_name
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Get "local" target name, i.e., target name without check of UID.
#
# @param [out] TARGET_NAME Target name used as argument to functions.
# @param [in]  TARGET_UID  "Global" target name, i.e., actual CMake target name.
#
# @returns Sets @p TARGET_NAME to the name of the build target with UID @p TARGET_UID.
#
# @sa get_target_name(), get_target_uid()

function( _get_target_name TARGET_NAME TARGET_UID )
	# Strip off namespace of current project.
	sanitize_for_regex( RE "${PROJECT_NAMESPACE_CMAKE}" )
	string( REGEX REPLACE "^${RE}\\." "" NAME "${UID}" )
	# Return
	set( ${TARGET_NAME} "${NAME}" PARENT_SCOPE )
endfunction()

# ============================================================================
# get_target_name
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Get "local" target name.
#
# @param [out] TARGET_NAME Target name used as argument to functions.
# @param [in]  TARGET_UID  "Global" target name, i.e., actual CMake target name.
#
# @returns Sets @p TARGET_NAME to the name of the build target with UID @p TARGET_UID.
#
# @sa get_target_uid()

function( get_target_name TARGET_NAME TARGET_UID )
	get_fully_qualified_target_uid( UID "${TARGET_UID}" )
	_get_target_name( NAME "${UID}" )
	set( ${TARGET_NAME} "${NAME}" PARENT_SCOPE )
endfunction()

# ============================================================================
# get_fully_qualified_target_uid
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Get fully-qualified target name.
#
# This function always returns a fully-qualified target UID.
#
# @param [out] TARGET_UID  Fully-qualified target UID.
# @param [in]  TARGET_NAME Target name used as argument to CMake functions.
#
# @sa get_target_uid()

function( get_fully_qualified_target_uid TARGET_UID TARGET_NAME )
	get_target_uid( UID "${TARGET_NAME}" )
	if( TARGET "${UID}" )
		get_target_property( IMPORTED "${UID}" IMPORTED )
		if( NOT IMPORTED )
			set( UID "${TOPLEVEL_PROJECT_NAMESPACE_CMAKE}.${UID}" )
		endif()
	endif()
endfunction()

# ============================================================================
# _get_target_type
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Get type name of target.
#
# @param [out] TYPE       The target's type name or NOTFOUND.
# @param [in]  TARGET_UID The UID of the target.

function( _get_target_type TYPE TARGET_UID )
	get_target_property( IMPORTED ${TARGET_UID} IMPORTED )
	if( IMPORTED )
		get_target_property( TYPE_OUT ${TARGET_UID} TYPE )
	else()
		get_target_property( TYPE_OUT ${TARGET_UID} BASIS_TYPE )
		if( NOT TYPE_OUT )
			get_target_property (TYPE_OUT ${TARGET_UID} TYPE )
		endif()
	endif()
	set( "${TYPE}" "${TYPE_OUT}" PARENT_SCOPE )
endfunction()

# ============================================================================
# get_target_type
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Get type name of target.
#
# @param [out] TYPE        The target's type name or NOTFOUND.
# @param [in]  TARGET_NAME The name of the target.

function( get_target_type TYPE TARGET_NAME )
	get_target_uid( TARGET_UID "${TARGET_NAME}" )
	if( TARGET ${TARGET_UID} )
		_get_target_type( TYPE_OUT ${TARGET_UID} )
	else()
		set( TYPE_OUT "NOTFOUND" )
	endif()
	set( "${TYPE}" "${TYPE_OUT}" PARENT_SCOPE )
endfunction()

# ============================================================================
# get_target_location
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Get location of build target output file(s).
#
# This convenience function can be used to get the full path of the output
# file(s) generated by a given build target. It is similar to the read-only
# @c LOCATION property of CMake targets and should be used instead of
# reading this property. In case of scripted libraries, this function returns
# the path of the root directory of the library that has to be added to the
# module search path.
#
# @note If the target is a binary built from C++ source files and the CMake
#       generator is an IDE such as Visual Studio or Xcode, the absolute
#       directory of the target location ends with the generator expression
#       "/$<${BASIS_GE_CONFIG}>" which is to be substituted by the respective
#       build configuration.
#
# @param [out] VAR         Path of build target output file.
# @param [in]  TARGET_NAME Name of build target.
# @param [in]  PART        Which file name component of the @c LOCATION
#                          property to return. See get_filename_component().
#                          If POST_INSTALL_RELATIVE is given as argument,
#                          @p VAR is set to the path of the installed file
#                          relative to the installation prefix. Similarly,
#                          POST_INSTALL sets @p VAR to the absolute path
#                          of the installed file post installation.
#
# @returns Path of output file similar to @c LOCATION property of CMake targets.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#prop_tgt:LOCATION

function( get_target_location VAR TARGET_NAME PART )
	get_target_uid( TARGET_UID "${TARGET_NAME}" )
	if( TARGET "${TARGET_UID}" )
		_get_target_name( TARGET_NAME "${TARGET_UID}" )
		_get_target_type( TYPE        "${TARGET_UID}" )
		get_target_property( IMPORTED ${TARGET_UID} IMPORTED )
		# ------------------------------------------------------------------------
		# Imported targets.
		#
		# Note: This might not be required though as even custom executable
		#       and library targets can be imported using CMake's
		#       add_executable( <NAME> IMPORTED ) and add_library( <NAME> <TYPE> IMPORTED )
		#       commands. Such executable can, for example, also be a BASH script.
		if( IMPORTED )
			# 1. Try IMPORTED_LOCATION_<CMAKE_BUILD_TYPE>.
			if( CMAKE_BUILD_TYPE )
				string( TOUPPER "${CMAKE_BUILD_TYPE}" U )
			else()
				set( U "NOCONFIG" )
			endif()
			get_target_property( LOCATION ${TARGET_UID} IMPORTED_LOCATION_${U} )
			# 2. Try IMPORTED_LOCATION.
			if( NOT LOCATION )
				get_target_property( LOCATION ${TARGET_UID} IMPORTED_LOCATION )
			endif()
			# 3. Prefer Release over all other configurations.
			if( NOT LOCATION )
				get_target_property( LOCATION ${TARGET_UID} IMPORTED_LOCATION_RELEASE )
			endif()
			# 4. Just use any of the imported configurations.
			if( NOT LOCATION )
				get_property( CONFIGS TARGET ${TARGET_UID} PROPERTY IMPORTED_CONFIGURATIONS )
				foreach( C IN LISTS CONFIGS )
					string( TOUPPER "${C}" C )
					get_target_property( LOCATION ${TARGET_UID} IMPORTED_LOCATION_${C} )
					if( LOCATION )
						break()
					endif()
				endforeach()
			endif()
			# Make path relative to CMAKE_INSTALL_PREFIX if POST_INSTALL_RELATIVE given.
			if( LOCATION AND ARGV2 MATCHES "POST_INSTALL_RELATIVE" )
				file( RELATIVE_PATH LOCATION "${CMAKE_INSTALL_PREFIX}" "${LOCATION}" )
			endif()
		# ------------------------------------------------------------------------
		# Non-imported targets.
		else()
			# Attention: The order of the matches/if cases matters here!
			# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			# Scripts.
			if( TYPE MATCHES "^SCRIPT_(EXECUTABLE|MODULE)$" )
				if( PART MATCHES "POST_INSTALL" )
					get_target_property( DIRECTORY ${TARGET_UID} INSTALL_DIRECTORY )
				else()
					get_target_property( DIRECTORY ${TARGET_UID} OUTPUT_DIRECTORY )
					if( DIRECTORY AND CMAKE_GENERATOR MATCHES "Visual Studio|Xcode" )
						set( DIRECTORY "${DIRECTORY}/$<${BASIS_GE_CONFIG}>" )
					endif()
				endif()
				get_target_property( FNAME ${TARGET_UID} OUTPUT_NAME )
			elseif( TYPE STREQUAL "^SCRIPT_MODULE$" )
				if( PART MATCHES "POST_INSTALL" )
					get_target_property( DIRECTORY ${TARGET_UID} INSTALL_DIRECTORY )
				else()
					get_target_property( COMPILE   ${TARGET_UID} COMPILE )
					get_target_property( DIRECTORY ${TARGET_UID} OUTPUT_DIRECTORY )
					if( DIRECTORY AND( COMPILE OR CMAKE_GENERATOR MATCHES "Visual Studio|Xcode" ) )
						set( DIRECTORY "${DIRECTORY}/$<${BASIS_GE_CONFIG}>" )
					endif()
				endif()
				get_target_property( FNAME ${TARGET_UID} OUTPUT_NAME )
			# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			# Libraries.
			elseif( TYPE MATCHES "LIBRARY|MODULE|MEX" )
				if( TYPE MATCHES "STATIC" )
					if( PART MATCHES "POST_INSTALL" )
						get_target_property( DIRECTORY ${TARGET_UID} ARCHIVE_INSTALL_DIRECTORY )
					else()
						get_target_property( DIRECTORY ${TARGET_UID} ARCHIVE_OUTPUT_DIRECTORY )
					endif()
					get_target_property( FNAME ${TARGET_UID} ARCHIVE_OUTPUT_NAME )
				else()
					if( PART MATCHES "POST_INSTALL" )
						get_target_property( DIRECTORY ${TARGET_UID} LIBRARY_INSTALL_DIRECTORY )
					else()
						get_target_property( DIRECTORY ${TARGET_UID} LIBRARY_OUTPUT_DIRECTORY )
					endif()
					get_target_property( FNAME ${TARGET_UID} LIBRARY_OUTPUT_NAME )
				endif()
			# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			# Executables.
			else()
				if( PART MATCHES "POST_INSTALL" )
					get_target_property( DIRECTORY ${TARGET_UID} RUNTIME_INSTALL_DIRECTORY )
				else()
					get_target_property( DIRECTORY ${TARGET_UID} RUNTIME_OUTPUT_DIRECTORY )
				endif()
				get_target_property( FNAME ${TARGET_UID} RUNTIME_OUTPUT_NAME )
			endif()
			if( DIRECTORY MATCHES "NOTFOUND" )
				message( FATAL_ERROR "Failed to get directory of ${TYPE} ${TARGET_UID}!"
									 " Check implementation of get_target_location()"
									 " and make sure that the required *INSTALL_DIRECTORY"
									 " property is set on the target!" )
			endif()
			if( DIRECTORY )
				# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				# Get output name of built file( if applicable ).
				if( NOT FNAME )
					get_target_property( FNAME ${TARGET_UID} OUTPUT_NAME )
				endif()
				if( NOT "^${TYPE}$" STREQUAL "^SCRIPT_LIBRARY$" )
					get_target_property( PREFIX ${TARGET_UID} PREFIX )
					get_target_property( SUFFIX ${TARGET_UID} SUFFIX )
					if( FNAME )
						set( TARGET_FILE "${FNAME}" )
					else()
						set( TARGET_FILE "${TARGET_NAME}" )
					endif()
					if( PREFIX )
						set( TARGET_FILE "${PREFIX}${TARGET_FILE}" )
					endif()
					if( SUFFIX )
						set( TARGET_FILE "${TARGET_FILE}${SUFFIX}" )
					elseif( WIN32 AND "^${TYPE}$" STREQUAL "^EXECUTABLE$" )
						set( TARGET_FILE "${TARGET_FILE}.exe" )
					endif()
				endif()
				# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				# Prepend $<CONFIG> "generator expression" for non-custom binaries
				# when built with an IDE such as Visual Studio or Xcode.
				if( "^${TYPE}$" STREQUAL "^EXECUTABLE$" OR "^${TYPE}$" STREQUAL "^LIBRARY$" )
					if( NOT PART MATCHES "INSTALL" )
						if( CMAKE_GENERATOR MATCHES "Visual Studio|Xcode" )
							set( DIRECTORY "${DIRECTORY}/$<${BASIS_GE_CONFIG}>" )
						endif()
					endif()
				endif()
				# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				# Assemble final path.
				if( PART MATCHES "POST_INSTALL_RELATIVE" )
					if( IS_ABSOLUTE "${DIRECTORY}" )
						file( RELATIVE_PATH DIRECTORY "${CMAKE_INSTALL_PREFIX}" "${DIRECTORY}" )
						if( NOT DIRECTORY )
							set( DIRECTORY "." )
						endif()
					endif()
				elseif( PART MATCHES "POST_INSTALL" )
					if( NOT IS_ABSOLUTE "${DIRECTORY}" )
						set( DIRECTORY "${CMAKE_INSTALL_PREFIX}/${DIRECTORY}" )
					endif()
				endif()
				if( TARGET_FILE )
					set( LOCATION "${DIRECTORY}/${TARGET_FILE}" )
				else()
					set( LOCATION "${DIRECTORY}" )
				endif()
			else()
				set( LOCATION "${DIRECTORY}" )
			endif()
		endif()
		# Get filename component.
		if( LOCATION AND PART MATCHES "(^|_ )(PATH|NAME|NAME_WE)$" )
			get_filename_component( LOCATION "${LOCATION}" "${CMAKE_MATCH_2}" )
		endif()
	else()
		message( FATAL_ERROR "get_target_location(): Unknown target ${TARGET_UID}" )
	endif()
	# Return.
	set( "${VAR}" "${LOCATION}" PARENT_SCOPE )
endfunction()

# ============================================================================
# get_target_link_libraries
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Get link libraries/dependencies of (imported) target.
#
# This function recursively adds the dependencies of the dependencies as well
# and returns them together with the list of the direct link dependencies.
#
# @param [out] LINK_DEPENDS List of all link dependencies. In case of scripts,
#                           the dependencies are the required modules or
#                           paths to required packages, respectively.
# @param [in]  TARGET_NAME  Name of the target.

function( get_target_link_libraries LINK_DEPENDS TARGET_NAME )
	get_target_uid (TARGET_UID "${TARGET_NAME}" )
	if( NOT TARGET "${TARGET_UID}" )
		message( FATAL_ERROR "get_target_link_libraries(): Unknown target: ${TARGET_UID}" )
	endif()
	if( _DEBUG AND _VERBOSE )
		message( "** get_target_link_libraries():" )
		message( "**   TARGET_NAME:     ${TARGET_NAME}" )
		message( "**   CURRENT_DEPENDS: ${ARGN}" )
	endif()
	# Get type of target.
	get_target_property( BASIS_TYPE ${TARGET_UID} BASIS_TYPE )
	# Get direct link dependencies of target.
	get_target_property( IMPORTED ${TARGET_UID} IMPORTED )
	if( IMPORTED )
		# 1. Try IMPORTED_LINK_INTERFACE_LIBRARIES_<CMAKE_BUILD_TYPE>.
		if( CMAKE_BUILD_TYPE )
			string( TOUPPER "${CMAKE_BUILD_TYPE}" U )
		else()
			set( U "NOCONFIG" )
		endif()
		get_target_property( DEPENDS ${TARGET_UID} "IMPORTED_LINK_INTERFACE_LIBRARIES_${U}" )
		# 2. Try IMPORTED_LINK_INTERFACE_LIBRARIES.
		if( NOT DEPENDS )
			get_target_property( DEPENDS ${TARGET_UID} "IMPORTED_LINK_INTERFACE_LIBRARIES" )
		endif()
		# 3. Prefer Release over all other configurations.
		if( NOT DEPENDS )
			get_target_property( DEPENDS ${TARGET_UID} "IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE" )
		endif()
		# 4. Just use any of the imported configurations.
		if( NOT DEPENDS )
			get_property( CONFIGS TARGET "${TARGET_UID}" PROPERTY IMPORTED_CONFIGURATIONS )
			foreach( C IN LISTS CONFIGS )
				get_target_property( DEPENDS ${TARGET_UID} "IMPORTED_LINK_INTERFACE_LIBRARIES_${C}" )
				if( DEPENDS )
					break()
				endif()
			endforeach()
		endif()
	# Otherwise, get LINK_DEPENDS property value.
	elseif( BASIS_TYPE MATCHES "^EXECUTABLE$|^(SHARED|STATIC|MODULE)_LIBRARY$" )
		get_target_property( DEPENDS ${TARGET_UID} BASIS_LINK_DEPENDS )
	else()
		get_target_property( DEPENDS ${TARGET_UID} LINK_DEPENDS )
	endif()
	if( NOT DEPENDS )
		set( DEPENDS )
	endif()
	# Prepend BASIS utilities if used (and added).
	if( BASIS_TYPE MATCHES "SCRIPT" )
		set( BASIS_UTILITIES_TARGETS )
		foreach( UID IN ITEMS ${TARGET_UID} ${DEPENDS} )
			if( TARGET "${UID}" )
				get_target_property( BASIS_UTILITIES ${UID} BASIS_UTILITIES )
				get_target_property( LANGUAGE        ${UID} LANGUAGE )
				if( BASIS_UTILITIES )
					set( BASIS_UTILITIES_TARGET )
						if( LANGUAGE MATCHES "[JP]YTHON" )
							get_source_target_name( BASIS_UTILITIES_TARGET "basis.py" NAME )
						elseif( LANGUAGE MATCHES "PERL" )
							get_source_target_name( BASIS_UTILITIES_TARGET "Basis.pm" NAME )
						elseif( LANGUAGE MATCHES "BASH" )
							get_source_target_name( BASIS_UTILITIES_TARGET "basis.sh" NAME )
					endif()
					if( BASIS_UTILITIES_TARGET )
						get_target_uid( BASIS_UTILITIES_TARGET ${BASIS_UTILITIES_TARGET} )
					endif()
					if( TARGET ${BASIS_UTILITIES_TARGET} )
						list( APPEND BASIS_UTILITIES_TARGETS ${BASIS_UTILITIES_TARGET} )
					endif()
				endif()
			endif()
		endforeach()
		if( BASIS_UTILITIES_TARGETS )
			list( INSERT DEPENDS 0 ${BASIS_UTILITIES_TARGETS} )
		endif()
	endif()
	# Convert target names to UIDs.
	set( _DEPENDS )
	foreach( LIB IN LISTS DEPENDS )
		get_target_uid( UID "${LIB}" )
		if( TARGET ${UID} )
			list( APPEND _DEPENDS "${UID}" )
		else()
			list( APPEND _DEPENDS "${LIB}" )
		endif()
	endforeach()
	set( DEPENDS "${_DEPENDS}" )
	unset( _DEPENDS )
	# Recursively add link dependencies of dependencies.
	# TODO implement it non-recursively for better performance.
	foreach (LIB IN LISTS DEPENDS )
		if( TARGET ${LIB} )
			list( FIND ARGN "${LIB}" IDX )		# Avoid recursive loop.
			if( IDX EQUAL -1 )
				basis_get_target_link_libraries (LIB_DEPENDS ${LIB} ${ARGN} ${DEPENDS} )
				list (APPEND DEPENDS ${LIB_DEPENDS} )
			endif()
		endif()
	endforeach()
	# Remove duplicate entries.
	if( DEPENDS )
		list( REMOVE_DUPLICATES DEPENDS )
	endif()
	# Return.
	set( ${LINK_DEPENDS} "${DEPENDS}" PARENT_SCOPE )
endfunction()

# ============================================================================
# join_build_targets
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Concatenates all build targets into a single string.
#
# This command evaluates the readonly BUILDSYSTEM_TARGETS property for the
# given directory name and appends the build targets at the end of the output
# variable.

# @param [in]  DIRECTORY    Directory name to get build targets.
# @param [out] OUTPUT       Output string variable name.
#
# @code
#   join_build_targets( ${CMAKE_CURRENT_LIST_DIR}/. buildTargets )
#   message( "${buildTargets}" )
# @endcode
#
# @returns Sets @p OUTPUT to the resulting string.

macro( join_build_targets DIRECTORY OUTPUT )
	set( name ${OUTPUT} )
	set( targets ${${name}} )
	# variable_value_status( var_dbg name targets )
	# message( STATUS "***** : ${var_dbg}" )

	set( curDir ${DIRECTORY} )
	get_property( theTargetList DIRECTORY ${curDir} PROPERTY BUILDSYSTEM_TARGETS )
	foreach( target IN LISTS theTargetList )
		set( targets "${targets}\n\t${target}" )
	endforeach()

	# variable_value_status( var_targets targets )
	# message( STATUS "***** : ${var_targets}" )

	get_directory_property( hasParent PARENT_DIRECTORY )
	if( hasParent )
		set( ${OUTPUT} "${targets}" PARENT_SCOPE )
	endif()
	set( ${OUTPUT} "${targets}" )
endmacro()

# ============================================================================
# process_generator_expressions
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Process generator expressions in arguments.
#
# This command evaluates the $&lt;TARGET_FILE:tgt&gt; and related generator
# expressions also for custom targets such as scripts and MATLAB Compiler
# targets. For other generator expressions whose argument is a target name,
# this function replaces the target name by the target UID, i.e., the actual
# CMake target name such that the expression can be evaluated by CMake.
# The following generator expressions are directly evaluated by this function:
# <table border=0>
#   <tr>
#     @tp <b><tt>$&lt;TARGET_FILE:tgt&gt;</tt></b> @endtp
#     <td>Absolute file path of built target.</td>
#   </tr>
#   <tr>
#     @tp <b><tt>$&lt;TARGET_FILE_POST_INSTALL:tgt&gt;</tt></b> @endtp
#     <td>Absolute path of target file after installation using the
#         current @c CMAKE_INSTALL_PREFIX.</td>
#   </tr>
#   <tr>
#     @tp <b><tt>$&lt;TARGET_FILE_POST_INSTALL_RELATIVE:tgt&gt;</tt></b> @endtp
#     <td>Path of target file after installation relative to @c CMAKE_INSTALL_PREFIX.</td>
#   </tr>
# </table>
# Additionally, the suffix <tt>_NAME</tt> or <tt>_DIR</tt> can be appended
# to the name of each of these generator expressions to get only the basename
# of the target file including the extension or the corresponding directory
# path, respectively.
#
# @param [out] ARGS Name of output list variable.
# @param [in]  ARGN List of arguments to process.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_test

function( process_generator_expressions ARGS )
set( ARGS_OUT )
	foreach( ARG IN LISTS ARGN )
		string( REGEX MATCHALL "\\$<.*TARGET.*:.*>" EXPRS "${ARG}" )
		foreach( EXPR IN LISTS EXPRS )
			if( EXPR MATCHES "\\$<(.*):(.*)>" )
				set( EXPR_NAME   "${CMAKE_MATCH_1}" )
				set( TARGET_NAME "${CMAKE_MATCH_2}" )
				# TARGET_FILE* expression, including custom targets.
				if( EXPR_NAME MATCHES "^TARGET_FILE(.*)" )
					if( NOT CMAKE_MATCH_1 )
						set( CMAKE_MATCH_1 "ABSOLUTE" )
					endif()
					string( REGEX REPLACE "^_" "" PART "${CMAKE_MATCH_1}" )
					get_target_location( ARG "${TARGET_NAME}" ${PART} )
				# Other generator expression supported by CMake
				# only replace target name, but do not evaluate expression.
				else()
					get_target_uid( TARGET_UID "${CMAKE_MATCH_2}" )
					string( REPLACE "${EXPR}" "$<${CMAKE_MATCH_1}:${TARGET_UID}>" ARG "${ARG}" )
				endif()
				if( _DEBUG AND _VERBOSE )
					message( "** process_generator_expressions():" )
					message( "**   Expression:  ${EXPR}" )
					message( "**   Keyword:     ${EXPR_NAME}" )
					message( "**   Argument:    ${TARGET_NAME}" )
					message( "**   Replaced by: ${ARG}" )
				endif()
			endif()
		endforeach()
		list( APPEND ARGS_OUT "${ARG}" )
	endforeach()
	set( ${ARGS} "${ARGS_OUT}" PARENT_SCOPE )
endfunction()

# ============================================================================
# append_to_each
# ============================================================================

# ----------------------------------------------------------------------------
##
#  @brief append_to_each takes an input list and appends a single element
#         to each item in that list and appends it to the output list.
#
# For example, this is useful for adding relative paths to the end of a list
# of paths.
#
#  @param OUTPUT_LIST Name of list that will be filled with appended names.
#  @param INPUT_LIST  Name of list that contains items to have text appended.
#  @param ITEM_TO_APPEND text to append to each item in the input list.

function( append_to_each OUTPUT_LIST INPUT_LIST ITEM_TO_APPEND )
	foreach( PATH IN LISTS ${INPUT_LIST} )
		list( APPEND ${OUTPUT_LIST} ${PATH}${ITEM_TO_APPEND} )
	endforeach()

	if( ${OUTPUT_LIST} )
		set( ${OUTPUT_LIST} ${${OUTPUT_LIST}} PARENT_SCOPE )
	endif()
endfunction()

# ============================================================================
# print_property_attributes
# ============================================================================

# ----------------------------------------------------------------------------
## @brief  Retrieve the property values from a variable or cache entry.
#
# Function to print out the property value, set-ness, defined-ness, brief
# docs and full docs. If it's for the VALUE property on a cache entry, the
# other known cache entry properties are also printed recursively.
#
# @param [in]  ENTRY Name of avariable or a cache entry.
# @param [in]  Property name of avariable or a cache entry.
#

function( print_property_attributes type name propName )
	if( "${type}" STREQUAL "CACHE" )
		set( propTypeArgs )
		list( APPEND propTypeArgs CACHE )
		list( APPEND propTypeArgs "${name}" )
		# list used because "set(propTypeArgs CACHE "${name}")" is an error...
		if( "${propName}" STREQUAL "" )
			set( propName VALUE )
		endif()
	elseif( "${type}" STREQUAL "VARIABLE" )
		set( propTypeArgs VARIABLE )
		set( propName "${name}" )		# Force propName to variable name for VARIABLE.
	else()
		message( "type '${type}' not implemented yet..." )
		return()
	endif()

	message( "propName='${propName}'" )		# The name of the property.

	get_property( propIsSet ${propTypeArgs} PROPERTY "${propName}" SET )
	message( "propIsSet='${propIsSet}'" )

	if( propIsSet )
		get_property( propValue ${propTypeArgs} PROPERTY "${propName}" )
		message( "propValue='${propValue}'" )

		get_property( propIsDefined ${propTypeArgs} PROPERTY "${propName}" DEFINED )
		message( "propIsDefined='${propIsDefined}'" )

		get_property( propBriefDocs ${propTypeArgs} PROPERTY "${propName}" BRIEF_DOCS )
		message( "propBriefDocs='${propBriefDocs}'" )

		get_property( propFullDocs ${propTypeArgs} PROPERTY "${propName}" FULL_DOCS )
		message( "propFullDocs='${propFullDocs}'" )

		if( "${type}" STREQUAL "CACHE" )
			if( "${propName}" STREQUAL "VALUE" )
				print_property_attributes( CACHE "${name}" ADVANCED )
				print_property_attributes( CACHE "${name}" HELPSTRING )
				print_property_attributes( CACHE "${name}" MODIFIED )
				print_property_attributes( CACHE "${name}" STRINGS )
				print_property_attributes( CACHE "${name}" TYPE )
			endif()
		endif()
	endif()
endfunction()

# ============================================================================
# print_variable_property_values
# ============================================================================

# ----------------------------------------------------------------------------
## @brief  Retrieve the property values from a variable or cache entry.
#
# Function to print out the property value, set-ness, defined-ness, brief
# docs and full docs. If it's for the VALUE property on a cache entry, the
# other known cache entry properties are also printed recursively.
#
# @param [in]  ENTRY Name of avariable or a cache entry.
#

function( print_variable_property_values varname )
	set( name "${varname}" )
	set( value "${${varname}}" )

	message( "name='${name}'" )
	message( "value='${value}'" )

	get_property( varPropIsSet VARIABLE PROPERTY "${name}" SET )
	if( varPropIsSet )
		message( "type='VARIABLE'" )
		print_property_attributes( VARIABLE "${name}" "" )
	else()
		message( "variable '${name}' is not set" )
	endif()

	get_property( cachePropIsSet CACHE "${name}" PROPERTY VALUE SET )
	if( cachePropIsSet )
		message( "type='CACHE'" )
		print_property_attributes( CACHE "${name}" "" )
	else()
		message( "cache entry '${name}' is not set" )
	endif()

	message( "" )
endfunction()

# ============================================================================
# add_project
# ============================================================================

# ----------------------------------------------------------------------------
## @brief  Add an external project.
#
# Usually, this is implemented using ExternalProject_Add() instead of
# add_subdirectory() to add the projects. I found add_custom_command() to work
# better since it doesn't do additional tasks in the background like creating
# stamp files and so on.
#
# The only downside is that every project needs to have an install target for
# this. So you need to add a dummy install command like install(CODE "") to
# projects that have no install command otherwise.
#
# @see https://stackoverflow.com/questions/31755870/how-to-use-libraries-within-my-cmake-project-that-need-to-be-installed-first
# @see https://stackoverflow.com/questions/31690253/how-to-install-subdirectories-to-different-locations-with-cmake

# @param [in]  Project name.
#

# add_project(<project> [DEPENDS project...])
function( add_project PROJECT )
	cmake_parse_arguments( PARAM "" "" "DEPENDS" ${ARGN} )
	add_custom_target( ${PROJECT} ALL DEPENDS ${PARAM_DEPENDS} )
	# Paths for this project.
	set( SOURCE_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT} )
	set( BUILD_DIR   ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT} )
	set( INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/${PROJECT} )
	# Configure.
	escape_list( CMAKE_MODULE_PATH )
	escape_list( CMAKE_PREFIX_PATH )
	add_custom_command( TARGET ${TARGET}
		COMMAND ${CMAKE_COMMAND}
			--no-warn-unused-cli
			"-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH_ESCAPED}"
			"-DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH_ESCAPED}"
			-DCMAKE_BINARY_DIR=${BUILD_DIR}
			-DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}
			-DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
			${SOURCE_DIR}
		WORKING_DIRECTORY ${BUILD_DIR} )
	# Build.
	add_custom_command( TARGET ${TARGET}
		COMMAND ${CMAKE_COMMAND}
			--build .
			--target install
		WORKING_DIRECTORY ${BUILD_DIR} )
	# Help later find_package() calls.
	append_global( CMAKE_PREFIX_PATH ${INSTALL_DIR} )
endfunction()

# ============================================================================
# escape_list( <list-name> )
# ============================================================================

# ----------------------------------------------------------------------------
## @brief  Helper function for add_project.
#

# @param [in]  List name.
#

function( escape_list LIST_NAME )
	string( REPLACE ";" "\;" ${LIST_NAME}_ESCAPED "${${LIST_NAME}}" )
	set( ${LIST_NAME}_ESCAPED "${${LIST_NAME}_ESCAPED}" PARENT_SCOPE )
endfunction()

# ============================================================================
# append_global( <name> value... )
# ============================================================================

# ----------------------------------------------------------------------------
## @brief  Helper function for add_project.
#

# @param [in]  Project name.
#

function( append_global NAME )
	set( COMBINED "${${NAME}}" "${ARGN}" )
	list( REMOVE_DUPLICATES COMBINED )
	set( ${NAME} "${COMBINED}" CACHE INTERNAL "" FORCE )
endfunction()


# ============================================================================
# Check_GLIBC_Version
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Check glibc version.
#
# Once done this will define
#   GLIBC_VERSION - glibc version
#
# @code
# if( LINUX )
# 	Check_GLIBC_Version()
# 	message( STATUS "glibc version : ${GLIBC_VERSION}" )
#	if( GLIBC_VERSION LESS_EQUAL "2.22" )
#		message( FATAL_ERROR "glibc version to low : ${GLIBC_VERSION}" )
#		#pragma GCC diagnostic push
#		#pragma GCC diagnostic ignored "-Wunused-parameter"
#	endif()
# endif()
# @endcode
#
# @param [out] OUT GLIBC_VERSION glibc version.

macro( Check_GLIBC_Version )
	execute_process(
		COMMAND ${CMAKE_C_COMPILER} -print-file-name=libc.so.6
		OUTPUT_VARIABLE GLIBC
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)
	get_filename_component( GLIBC ${GLIBC} REALPATH )
	get_filename_component( GLIBC_VERSION ${GLIBC} NAME )
	string( REPLACE "libc-" "" GLIBC_VERSION ${GLIBC_VERSION} )
	string( REPLACE ".so" "" GLIBC_VERSION ${GLIBC_VERSION} )
	if( NOT GLIBC_VERSION MATCHES "^[0-9.]+$" )
		message( FATAL_ERROR "Unknown glibc version: ${GLIBC_VERSION}" )
	endif()
endmacro()

## @}
# end of Doxygen group
