cmake_minimum_required (VERSION 2.8.4)

set(CMAKE_LEGACY_CYGWIN_WIN32 0)

SET(LUA_DIR ../lua5.1)

include_directories (${LUA_DIR}/Include)
link_directories (${LUA_DIR}/Include)

add_library (lfs SHARED lfs.c)

target_link_libraries (lfs lua)
