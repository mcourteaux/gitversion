set(DIR_OF_GITVERSION_TOOL "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL "DIR_OF_GITVERSION_TOOL")

function (_create_git_version_file ${TARGET})
  file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/messmer_gitversion_${TARGET}")
  file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/messmer_gitversion_${TARGET}/${TARGET}")

  if(DEFINED ENV{PYTHONPATH})
      set(ENV{PYTHONPATH} "${DIR_OF_GITVERSION_TOOL}/src:ENV{PYTHONPATH}")
  else()
      set(ENV{PYTHONPATH} "${DIR_OF_GITVERSION_TOOL}/src")
  endif()
  execute_process(COMMAND /usr/bin/env python3 -m gitversionbuilder --namespace ${TARGET} --lang cpp --dir "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/messmer_gitversion_${TARGET}/${TARGET}/gitversion.cpp"
		  RESULT_VARIABLE result)
  if(NOT ${result} EQUAL 0)
    message(FATAL_ERROR "Error running messmer/git-version tool. Return code is: ${result}")
  endif()
endfunction (_create_git_version_file)

function(_set_gitversion_cmake_variable TARGET OUTPUT_VARIABLE)
  # Load version string and write it to a cmake variable so it can be accessed from cmake.
  file(READ "${CMAKE_CURRENT_BINARY_DIR}/messmer_gitversion_${TARGET}/${TARGET}/gitversion.cpp" VERSION_H_FILE_CONTENT)
  string(REGEX REPLACE ".*VERSION_STRING = \"([^\"]*)\".*" "\\1" VERSION_STRING "${VERSION_H_FILE_CONTENT}")
  message(STATUS "Version from git: ${VERSION_STRING}")
  set(${OUTPUT_VARIABLE} "${VERSION_STRING}" CACHE INTERNAL "${OUTPUT_VARIABLE}")
endfunction(_set_gitversion_cmake_variable)

######################################################
# Add git version information
# Uses:
#   TARGET_GIT_VERSION_INIT(buildtarget)
# Then, you can write in your source file:
#   #include <$TARGET/gitversion.h>
#   cout << gitversion::VERSION.toString() << endl;
######################################################
function(target_git_version_init TARGET)
  _create_git_version_file(${TARGET})
  add_library(${TARGET}_version_lib STATIC "${CMAKE_CURRENT_BINARY_DIR}/messmer_gitversion_${TARGET}/${TARGET}/gitversion.cpp")
  #target_include_directories(${TARGET} PUBLIC "${CMAKE_CURRENT_BINARY_DIR}/messmer_gitversion_${TARGET}")
  target_link_libraries(${TARGET} PUBLIC ${TARGET}_version_lib)
  _set_gitversion_cmake_variable(${TARGET} GITVERSION_VERSION_STRING)
endfunction(target_git_version_init)

######################################################
# Load git version information into a cmake variable
# Uses:
#  GET_GIT_VERSION(OUTPUT_VARIABLE)
#  MESSAGE(STATUS "The version is ${OUTPUT_VARIABLE}")
######################################################
function(get_git_version TARGET OUTPUT_VARIABLE)
  _create_git_version_file(${TARGET})
  _set_gitversion_cmake_variable(${OUTPUT_VARIABLE})
endfunction(get_git_version OUTPUT_VARIABLE)
