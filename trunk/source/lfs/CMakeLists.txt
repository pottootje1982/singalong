cmake_minimum_required (VERSION 2.6)

SET(LUA_DIR ../lua5.1)

include_directories (${LUA_DIR}/Include)
link_directories (${LUA_DIR}/Include)

add_library (lfs lfs.c lfs.def)
