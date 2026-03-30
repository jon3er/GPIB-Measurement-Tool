cmake_minimum_required(VERSION 3.15)
project(TEST-GPIB-Terminal VERSION 0.2)

cmake_policy(SET CMP0003 NEW) # Linker Pfade
if(POLICY CMP0167)
    cmake_policy(SET CMP0167 NEW) # FindBoost Deprecation
endif()

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# 1. wxWidgets & local Boost (header-only using asio)
find_package(wxWidgets REQUIRED COMPONENTS core base adv net richtext)
include(${wxWidgets_USE_FILE})

# Use local Boost from third-party (header-only)
set(Boost_INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/third-party/boost_1_90_0")
if(NOT EXISTS "${Boost_INCLUDE_DIRS}/boost/asio.hpp")
    message(FATAL_ERROR "Boost not found in ${Boost_INCLUDE_DIRS}. Please ensure boost_1_90_0 is extracted there.")
endif()

# 2. FTDI & Mathplot
set(MATHPLOT_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/third-party")
if(WIN32)
    set(FTDI_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/third-party/FTDI")
    set(FTDI_LIBRARY "${CMAKE_CURRENT_SOURCE_DIR}/third-party/FTDI/ftd2xx.lib")
else()
    find_path(FTDI_INCLUDE_DIR ftd2xx.h REQUIRED)
    find_library(FTDI_LIBRARY NAMES ftd2xx REQUIRED)
endif()

set(VCPKG_APPLOCAL_DEPS ON CACHE BOOL "")
# supress mathplot warnings

# 3. Sources (mathplot only, exclude boost library)
file(GLOB_RECURSE SOURCE_FILES CONFIGURE_DEPENDS "src/**/*.cpp" "third-party/mathplot.cpp")

add_executable(TEST-GPIB-Terminal ${SOURCE_FILES})
if(WIN32)
    set_target_properties(TEST-GPIB-Terminal PROPERTIES WIN32_EXECUTABLE YES)
endif()

# --- 6. Präprozessor-Fixes ---
target_compile_definitions(TEST-GPIB-Terminal PRIVATE 
    wxUSE_GUI=1
)

if(WIN32)
    target_compile_definitions(TEST-GPIB-Terminal PRIVATE 
        WXUSINGDLL
        _WIN32_WINNT=0x0A00 # Fix fuer Boost: Ziel Windows 10
        _CRT_SECURE_NO_WARNINGS
    )
endif()

# Suppress mathplot C4996 warnings (SetStyle)
if(MSVC)
    target_compile_options(TEST-GPIB-Terminal PRIVATE /wd4996)
endif()

# 4. Linking & Includes
target_link_libraries(TEST-GPIB-Terminal PRIVATE 
    ${wxWidgets_LIBRARIES} 
    ${FTDI_LIBRARY}
)

target_include_directories(TEST-GPIB-Terminal PRIVATE 
    "include"
    "include/data"
    "include/gui"
    "include/gui/FunctionWindow"
    "include/gui/helpTab"
    "include/gui/MesurementWindow"
    "include/gui/MesurementWindow/InputDialog"
    "include/gui/SettingsWindow"
    "include/gui/TerminalWindow"
    "include/hardware"
    "include/Plotter"
    ${FTDI_INCLUDE_DIR}
    ${MATHPLOT_INCLUDE_DIR}
    ${Boost_INCLUDE_DIRS}
    ${wxWidgets_INCLUDE_DIRS}
)

# 5. Automatischer DLL-Export (vcpkg Feature)
set(VCPKG_APPLOCAL_DEPS ON)