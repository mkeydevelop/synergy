# synergy -- mouse and keyboard sharing utility
# Copyright (C) 2015 Synergy Si Ltd.
# 
# This package is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# found in the file LICENSE that should have accompanied this file.
# 
# This package is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

file(GLOB headers "*.h")
file(GLOB sources "*.cpp")

if (SYNERGY_ADD_HEADERS)
	list(APPEND sources ${headers})
endif()

if (WIN32 AND NOT MINGW)
	if(CMAKE_SIZEOF_VOID_P EQUAL 8)
		set(OPENSSL_PLAT_DIR openssl-win64)
	else()
		set(OPENSSL_PLAT_DIR openssl-win32)
	endif()
	set(OPENSSL_INCLUDE ../../../../ext/${OPENSSL_PLAT_DIR}/include)
endif()

if (APPLE)
	set(OPENSSL_PLAT_DIR openssl-osx)
	set(OPENSSL_INCLUDE ../../../../ext/${OPENSSL_PLAT_DIR}/include)
endif()

include_directories(
	../../../lib/
	../../../..
	${OPENSSL_INCLUDE}
)

if (CASE_SENSITIVE)
	include_directories(
		../../arch/mingw
	)
endif()

add_library(ns SHARED ${sources})

if (WIN32)
	if (MINGW)
		set(OPENSSL_LIBS ssl crypto)
	else()
		set(OPENSSL_LIBS
			ws2_32.lib
			${CMAKE_SOURCE_DIR}/ext/${OPENSSL_PLAT_DIR}/lib/libeay32.lib
			${CMAKE_SOURCE_DIR}/ext/${OPENSSL_PLAT_DIR}/lib/ssleay32.lib
		)
	endif()
endif()

if (UNIX)
	if (APPLE)
		set(OPENSSL_LIBS
		${CMAKE_SOURCE_DIR}/ext/${OPENSSL_PLAT_DIR}/libssl.a
		${CMAKE_SOURCE_DIR}/ext/${OPENSSL_PLAT_DIR}/libcrypto.a
		)
	else()
		set(OPENSSL_LIBS ssl crypto)
	endif()
endif()


if (NOT MINGW)
	target_link_libraries(ns
		arch base client common io mt net ipc platform server synergy ${libs} ${OPENSSL_LIBS})
else()
	target_link_libraries(ns
		-Wl,--start-group arch base client common io mt net ipc platform server synergy -Wl,--end-group ${libs} ${OPENSSL_LIBS})
endif()

if (WIN32 AND NOT MINGW)
	add_custom_command(
		TARGET ns 
		POST_BUILD
		COMMAND xcopy /Y /Q
			..\\..\\..\\..\\..\\lib\\${CMAKE_CFG_INTDIR}\\ns.*
			..\\..\\..\\..\\..\\bin\\${CMAKE_CFG_INTDIR}\\plugins\\
	)
endif()

if (UNIX OR MINGW)
	if (APPLE)
		add_custom_command(
			TARGET ns
			POST_BUILD
			COMMAND
				mkdir -p
				${CMAKE_SOURCE_DIR}/bin/${CMAKE_CFG_INTDIR}/plugins
				&&
				cp
				${CMAKE_SOURCE_DIR}/lib/${CMAKE_CFG_INTDIR}/libns.*
				${CMAKE_SOURCE_DIR}/bin/${CMAKE_CFG_INTDIR}/plugins/
		)
	else()
		if (CMAKE_BUILD_TYPE STREQUAL Debug)
			add_custom_command(
				TARGET ns
				POST_BUILD
				COMMAND mkdir -p
					${CMAKE_SOURCE_DIR}/bin/debug/plugins
					&&
					cp
					${CMAKE_SOURCE_DIR}/lib/debug/libns.*
					${CMAKE_SOURCE_DIR}/bin/debug/plugins/
			)
		else()
			add_custom_command(
				TARGET ns
				POST_BUILD
				COMMAND mkdir -p
					${CMAKE_SOURCE_DIR}/bin/plugins
					&&
					cp
					${CMAKE_SOURCE_DIR}/lib/libns.*
					${CMAKE_SOURCE_DIR}/bin/plugins/
			)
		endif()
	endif()
endif()
