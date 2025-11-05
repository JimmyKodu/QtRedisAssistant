cmake_minimum_required(VERSION 3.16)

project(QtRedisAssistant VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Find Qt6 or Qt5
find_package(Qt6 COMPONENTS Core Widgets Network QUIET)
if (NOT Qt6_FOUND)
    find_package(Qt5 5.15 REQUIRED COMPONENTS Core Widgets Network)
endif()

# Source files
set(SOURCES
    src/main.cpp
    src/mainwindow.cpp
    src/redisconnection.cpp
)

set(HEADERS
    src/mainwindow.h
    src/redisconnection.h
)

set(UI_FILES
    src/mainwindow.ui
)

# Create executable
add_executable(${PROJECT_NAME} ${SOURCES} ${HEADERS} ${UI_FILES})

# Link libraries
if (Qt6_FOUND)
    target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt6::Core
        Qt6::Widgets
        Qt6::Network
    )
else()
    target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt5::Core
        Qt5::Widgets
        Qt5::Network
    )
endif()

# Install targets
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
)

# Windows deployment - install Qt and MinGW runtime DLLs
if(WIN32)
    # Find Qt installation path
    if (Qt6_FOUND)
        get_target_property(_qmake_executable Qt6::qmake IMPORTED_LOCATION)
    else()
        get_target_property(_qmake_executable Qt5::qmake IMPORTED_LOCATION)
    endif()
    get_filename_component(_qt_bin_dir "${_qmake_executable}" DIRECTORY)
    
    # Use windeployqt for Qt dependencies
    find_program(WINDEPLOYQT_EXECUTABLE windeployqt HINTS "${_qt_bin_dir}")
    
    # Install Qt runtime dependencies
    if(WINDEPLOYQT_EXECUTABLE)
        install(CODE "
            execute_process(
                COMMAND \"${WINDEPLOYQT_EXECUTABLE}\" --release --no-translations --no-system-d3d-compiler --no-opengl-sw \"\${CMAKE_INSTALL_PREFIX}/bin/${PROJECT_NAME}.exe\"
                WORKING_DIRECTORY \"\${CMAKE_INSTALL_PREFIX}/bin\"
            )
        ")
    endif()
    
    # Install MinGW runtime DLLs
    # These are typically in the same directory as the compiler
    set(MINGW_RUNTIME_DLLS
        libgcc_s_seh-1.dll
        libstdc++-6.dll
        libwinpthread-1.dll
    )
    
    foreach(dll ${MINGW_RUNTIME_DLLS})
        if(EXISTS "${_qt_bin_dir}/${dll}")
            install(FILES "${_qt_bin_dir}/${dll}" DESTINATION bin)
        endif()
    endforeach()
endif()
