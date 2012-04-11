# Copyright (C) 2007-2009 LuaDist.
# Created by Peter Kapec
# Redistribution and use of this file is allowed according to the terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own license.

PROJECT(cd C)
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
INCLUDE(dist.cmake)

# Macros
	MACRO(ADD_PREFIX prefix rootlist)
	  SET(outlist )
	  FOREACH(root ${${rootlist}})
		LIST(APPEND outlist ${prefix}${root})
	  ENDFOREACH(root)
	  SET(${rootlist} ${outlist})
	ENDMACRO(ADD_PREFIX)

# find headers & libs
	FIND_PACKAGE(Lua51 REQUIRED)
	INCLUDE_DIRECTORIES (${LUA_INCLUDE_DIR})

	FIND_PATH( CD_INCLUDE_DIR NAMES cd.h )
	INCLUDE_DIRECTORIES (${CD_INCLUDE_DIR})
	FIND_LIBRARY( CD_LIBRARY NAMES cd)
	FIND_LIBRARY( CDPDF_LIBRARY NAMES cdpdf)
	FIND_LIBRARY( CDCONTEXTPLUS_LIBRARY NAMES cdcontextplus)
	FIND_LIBRARY( CDCAIRO_LIBRARY NAMES cdcairo)
	FIND_LIBRARY( CDGL_LIBRARY NAMES cdgl)

	FIND_PATH( IM_INCLUDE_DIR NAMES im.h )
	INCLUDE_DIRECTORIES (${IM_INCLUDE_DIR})
	FIND_LIBRARY( IM_LIBRARY NAMES im)
	FIND_LIBRARY( IMLUA_LIBRARY NAMES imlua libimlua)

# set stuff
	# ADD_DEFINITIONS(-DCD_NO_OLD_INTERFACE -DFT2_BUILD_LIBRARY)
	ADD_DEFINITIONS(-DCD_NO_OLD_INTERFACE )
	INCLUDE_DIRECTORIES ("include" )

# cdlua lib
	SET(SRC_CDLUA  cdlua5.c cdvoid5.c cdlua5ctx.c cdlua5_active.c cdlua5_canvas.c cdlua5.def)
	ADD_PREFIX(src/lua5/ SRC_CDLUA)

	ADD_LIBRARY(cdlua SHARED ${SRC_CDLUA} )
	TARGET_LINK_LIBRARIES(cdlua ${LUA_LIBRARY} ${CD_LIBRARY})
	
# cdlua module
	ADD_LIBRARY(cdlua_module MODULE cdlua_module.c src/lua5/cdlua5.def)
	TARGET_LINK_LIBRARIES(cdlua_module cdlua)
	SET_TARGET_PROPERTIES(cdlua_module PROPERTIES PREFIX "" OUTPUT_NAME cdlua CLEAN_DIRECT_OUTPUT 1 )

# cdluapdf
	IF(CDPDF_LIBRARY)
		ADD_LIBRARY(cdluapdf MODULE src/lua5/cdluapdf5.c src/lua5/cdluapdf5.def)
		TARGET_LINK_LIBRARIES(cdluapdf cdlua ${CDPDF_LIBRARY} )
		SET_TARGET_PROPERTIES(cdluapdf PROPERTIES PREFIX "")
	ENDIF()
	
# cdluacontextplus
	IF(CDCONTEXTPLUS_LIBRARY)
		ADD_LIBRARY(cdluacontextplus MODULE src/lua5/cdluacontextplus5.c)
		SET_TARGET_PROPERTIES(cdluacontextplus PROPERTIES PREFIX "")

		IF(WIN32)
			TARGET_LINK_LIBRARIES(cdluacontextplus cdlua ${CDCONTEXTPLUS_LIBRARY} src/lua5/cdluacontextplus5.def)
		ELSE()
			FIND_PACKAGE(X11)
			INCLUDE_DIRECTORIES(${X11_INCLUDE_DIR})

			TARGET_LINK_LIBRARIES(cdluacontextplus cdlua ${CDCONTEXTPLUS_LIBRARY} ${X11_Xft_LIB})
		ENDIF ()

		INSTALL(TARGETS cdluacontextplus DESTINATION ${INSTALL_CMOD})
	ENDIF()

# cdluacairo
#~ 	FIND_PACKAGE(GTK2 COMPONENTS gtk)
#~ 	IF(GTK2_FOUND)
	IF(CDCAIRO_LIBRARY)
		ADD_LIBRARY(cdluacairo MODULE src/lua5/cdluacairo5.c src/lua5/cdluacairo5.def)
		TARGET_LINK_LIBRARIES(cdluacairo cdlua ${CDPDF_LIBRARY} )
		SET_TARGET_PROPERTIES(cdluacairo PROPERTIES PREFIX "")	
		
		INSTALL(TARGETS cdluacairo DESTINATION ${INSTALL_CMOD})
	ENDIF()

# cdluaim
	IF(IM_LIBRARY AND IMLUA_LIBRARY)
		ADD_LIBRARY(cdluaim MODULE src/lua5/cdluaim5.c src/lua5/cdluaim5.def)
		TARGET_LINK_LIBRARIES(cdluaim cdlua ${IMLUA_LIBRARY} ${IM_LIBRARY} )
		SET_TARGET_PROPERTIES(cdluaim PROPERTIES PREFIX "")
	ENDIF()
	
# cdluagl
	IF(CDGL_LIBRARY)
		ADD_LIBRARY(cdluagl MODULE src/lua5/cdluagl5.c src/lua5/cdluagl5.def)
		TARGET_LINK_LIBRARIES(cdluagl cdlua ${CDGL_LIBRARY})
		SET_TARGET_PROPERTIES(cdluagl PROPERTIES PREFIX "")	
		SET(CDLUAGL_LIB cdluagl)
	ENDIF()

# install all Lua modules
	INSTALL(TARGETS cdlua RUNTIME DESTINATION ${INSTALL_BIN} LIBRARY DESTINATION ${INSTALL_LIB} ARCHIVE DESTINATION ${INSTALL_LIB})
	INSTALL(TARGETS cdlua_module cdluapdf cdluaim ${CDLUAGL_LIB} DESTINATION ${INSTALL_CMOD})
