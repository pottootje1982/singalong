# Copyright (C) 2007-2009 LuaDist.
# Created by Peter Kapec
# Redistribution and use of this file is allowed according to the terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own license.


PROJECT(im C)
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
INCLUDE(dist.cmake)

#SET(CMAKE_BACKWARDS_COMPATIBILITY  "2.2")	# !!! bug: CMake won't find libm needed by FindLua51 (Ubuntu Karmic 64bit) !!!
#CMAKE_POLICY(SET CMP0001 NEW)

find_package(Lua51 REQUIRED)
include_directories(${LUA_INCLUDE_DIR}) 

# Discard embedded Lua sources.  We'll regenerate.
FILE(REMOVE_RECURSE ${CMAKE_CURRENT_SOURCE_DIR}/srclua5/loh)
ADD_DEFINITIONS(-DIMLUA_USELOH)

# Microsoft C++ definitions
IF (MSVC)
	ADD_DEFINITIONS(-D_CRT_SECURE_NO_WARNINGS)
ENDIF (MSVC)

# Macros
	MACRO(ADD_PREFIX prefix rootlist)
		SET(outlist )
		FOREACH(root ${${rootlist}})
			LIST(APPEND outlist ${prefix}${root})
		ENDFOREACH(root)
		SET(${rootlist} ${outlist})
	ENDMACRO(ADD_PREFIX)

# find headers & libs
	FIND_PATH( IM_INCLUDE_DIR NAMES im.h )
	INCLUDE_DIRECTORIES (${IM_INCLUDE_DIR})

	FIND_LIBRARY( IM_LIBRARY NAMES im)
	FIND_LIBRARY( IM_LIBRARY_PROCESS NAMES im_process)
	FIND_LIBRARY( IM_LIBRARY_FFTW NAMES im_fftw)

	FIND_LIBRARY( IM_LIBRARY_AVI NAMES im_avi)
	FIND_LIBRARY( IM_LIBRARY_CAPTURE NAMES im_capture)
	FIND_LIBRARY( IM_LIBRARY_WMV NAMES im_wmv)
	FIND_LIBRARY( IM_LIBRARY_JP2 NAMES im_jp2)

# imlua lib
	INCLUDE_DIRECTORIES (include ${CMAKE_CURRENT_BINARY_DIR} src/lua5)

	SET(SRC_IMLUALIB lua5/imlua.c lua5/imlua_aux.c lua5/imlua_convert.c lua5/imlua_file.c lua5/imlua_image.c lua5/imlua_palette.c lua5/imlua_util.c lua5/imlua.def)
	ADD_PREFIX(src/ SRC_IMLUALIB)

	ADD_LIBRARY(imlua SHARED ${SRC_IMLUALIB})
	#INSTALL_LUA_MODULE(imlua ${SRC_IMLUALIB})
	TARGET_LINK_LIBRARIES(imlua ${LUA_LIBRARY} ${IM_LIBRARY})

# imlua module
	INSTALL_LUA_MODULE(imlua_module src/lua5/imlua_module.c src/lua5/imlua.def LINK imlua)
	SET_TARGET_PROPERTIES(imlua_module PROPERTIES OUTPUT_NAME imlua)

# imlua_process5
	SET(SRC_IMLUA_PROCESS src/lua5/imlua_process.c src/lua5/imlua_kernel.c)
	INSTALL_LUA_MODULE(imlua_process ${SRC_IMLUA_PROCESS} LINK imlua ${IM_LIBRARY_PROCESS})

# imlua_fftw5
	INSTALL_LUA_MODULE(imlua_fftw src/lua5/imlua_fftw.c src/lua5/imlua_fftw.def LINK imlua ${IM_LIBRARY_FFTW})

# imlua_avi
	IF(IM_LIBRARY_AVI)
		SET(SRC_IMLUA_AVI src/lua5/imlua_avi.c)
		INSTALL_LUA_MODULE(imlua_avi ${SRC_IMLUA_AVI} src/lua5/imlua_avi.def LINK imlua ${IM_LIBRARY_AVI} )
	ENDIF()


# imlua_capture
	IF(IM_LIBRARY_CAPTURE)
		SET(SRC_IMLUA_CAPTURE src/lua5/imlua_capture.c)
		INSTALL_LUA_MODULE(imlua_capture ${SRC_IMLUA_CAPTURE} src/lua5/imlua_capture.def LINK imlua ${IM_LIBRARY_CAPTURE})
	ENDIF()

# imlua_wmv
	IF(IM_LIBRARY_WMV)
		SET(SRC_IMLUA_WMV src/lua5/imlua_wmv.c)
		INSTALL_LUA_MODULE(imlua_wmv ${SRC_IMLUA_WMV} src/lua5/imlua_wmv.def LINK imlua ${IM_LIBRARY} ${IM_LIBRARY_WMV})
	ENDIF()

# imlua_jp2
	IF(IM_LIBRARY_JP2)	
		SET(SRC_IMLUA_JP2 src/lua5/imlua_jp2.c)
		INSTALL_LUA_MODULE(imlua_jp2 ${SRC_IMLUA_JP2} src/lua5/imlua_jp2.def LINK imlua  ${IM_LIBRARY_JP2})
	ENDIF()
# Embed Lua code into shared library.
FIND_PROGRAM( LUA lua )
SET(BIN2C ${CMAKE_CURRENT_SOURCE_DIR}/src/bin2c.lua)

INCLUDE_DIRECTORIES(${CMAKE_BINARY_DIR}/loh)
SET(LUAMODS fftw process convert image)
FOREACH(x ${LUAMODS})
	ADD_CUSTOM_COMMAND(
		OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/loh/im_${x}.loh
		COMMAND ${CMAKE_COMMAND} "-E" "make_directory" "${CMAKE_BINARY_DIR}/loh"
		COMMAND ${LUA} ${BIN2C} "${CMAKE_CURRENT_SOURCE_DIR}/src/lua5/im_${x}.lua" ">" "${CMAKE_BINARY_DIR}/loh/im_${x}.loh"
		VERBATIM
	)
	SET_PROPERTY(SOURCE src/lua5/imlua_${x}.c APPEND PROPERTY OBJECT_DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/loh/im_${x}.loh)	
ENDFOREACH(x)


# install all Lua modules
	INSTALL(TARGETS imlua RUNTIME DESTINATION ${INSTALL_BIN} LIBRARY DESTINATION ${INSTALL_LIB} ARCHIVE DESTINATION ${INSTALL_LIB})
