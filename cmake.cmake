set(DIR_OF_GITVERSION_TOOL "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL "DIR_OF_GITVERSION_TOOL")

function (_CREATE_GIT_VERSION_FILE ${TARGET})
  FILE(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/messmer_gitversion_${TARGET}")
  FILE(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/messmer_gitversion_${TARGET}/${TARGET}")

  IF(DEFINED ENV{PYTHONPATH})
      SET(ENV{PYTHONPATH} "${DIR_OF_GITVERSION_TOOL}/src:ENV{PYTHONPATH}")
  ELSE()
      SET(ENV{PYTHONPATH} "${DIR_OF_GITVERSION_TOOL}/src")
  ENDIF()
  EXECUTE_PROCESS(COMMAND /usr/bin/env python3 -m gitversionbuilder --namespace ${TARGET} --lang cpp --dir "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/messmer_gitversion_${TARGET}/${TARGET}/gitversion.hpp"
		  RESULT_VARIABLE result)
  IF(NOT ${result} EQUAL 0)
    MESSAGE(FATAL_ERROR "Error running messmer/git-version tool. Return code is: ${result}")
  ENDIF()
endfunction (_CREATE_GIT_VERSION_FILE)

function(_SET_GITVERSION_CMAKE_VARIABLE TARGET OUTPUT_VARIABLE)
  # Load version string and write it to a cmake variable so it can be accessed from cmake.
  FILE(READ "${CMAKE_CURRENT_BINARY_DIR}/messmer_gitversion_${TARGET}/${TARGET}/gitversion.hpp" VERSION_H_FILE_CONTENT)
  STRING(REGEX REPLACE ".*VERSION_STRING = \"([^\"]*)\".*" "\\1" VERSION_STRING "${VERSION_H_FILE_CONTENT}")
  MESSAGE(STATUS "Version from git: ${VERSION_STRING}")
  SET(${OUTPUT_VARIABLE} "${VERSION_STRING}" CACHE INTERNAL "${OUTPUT_VARIABLE}")
endfunction(_SET_GITVERSION_CMAKE_VARIABLE)

######################################################
# Add git version information
# Uses:
#   TARGET_GIT_VERSION_INIT(buildtarget)
# Then, you can write in your source file:
#   #include <$TARGET/gitversion.h>
#   cout << gitversion::VERSION.toString() << endl;
######################################################
function(TARGET_GIT_VERSION_INIT TARGET)
  _CREATE_GIT_VERSION_FILE(${TARGER})
  TARGET_INCLUDE_DIRECTORIES(${TARGET} PUBLIC "${CMAKE_CURRENT_BINARY_DIR}/messmer_gitversion_${TARGET}")
  _SET_GITVERSION_CMAKE_VARIABLE(${TARGET} GITVERSION_VERSION_STRING)
endfunction(TARGET_GIT_VERSION_INIT)

######################################################
# Load git version information into a cmake variable
# Uses:
#  GET_GIT_VERSION(OUTPUT_VARIABLE)
#  MESSAGE(STATUS "The version is ${OUTPUT_VARIABLE}")
######################################################
function(GET_GIT_VERSION TARGET OUTPUT_VARIABLE)
  _CREATE_GIT_VERSION_FILE(${TARGET})
  _SET_GITVERSION_CMAKE_VARIABLE(${OUTPUT_VARIABLE})
endfunction(GET_GIT_VERSION OUTPUT_VARIABLE)
