project(LuaBindings)

set(GUI_TYPE WIN32)

set(SOURCES 
	"GameWinMain.h"
	"GameWinMain.cpp"
	"Game.cpp"
	"Game.h"	
	)

add_executable(${PROJECT_NAME} WIN32  ${SOURCES} )
set_target_properties(${PROJECT_NAME} PROPERTIES WIN32_EXECUTABLE YES)

add_dependencies(${PROJECT_NAME} EngineLibrary)
target_link_libraries(${PROJECT_NAME} PRIVATE EngineLibrary)

set_property(GLOBAL PROPERTY VS_STARTUP_PROJECT ${PROJECT_NAME})

include(FetchContent)

# Fetch LUA
# ++++++++++
FetchContent_Declare(
    lua
    URL https://github.com/marovira/lua/archive/refs/tags/5.4.4.tar.gz
    GIT_SHALLOW    TRUE
)
FetchContent_MakeAvailable(lua)


# Fetch SOL2
# ++++++++++
FetchContent_Declare(
    sol2
    URL https://github.com/ThePhD/sol2/archive/refs/tags/v3.3.0.tar.gz
    GIT_SHALLOW    TRUE
)
FetchContent_MakeAvailable(sol2)
target_link_libraries(${PROJECT_NAME} PRIVATE lua::lua sol2)


list(APPEND LUA_SOURCES 
            "script_Breakout.lua"
            "script_Tetris.lua"
            "annotations.lua"
)

#Copy Resources
message(STATUS "BINARY DIR: ${CMAKE_CURRENT_BINARY_DIR}")
message(STATUS "CMAKE EXE: ${CMAKE_COMMAND}")

#https://www.youtube.com/watch?v=sTuIRzrB2dA

add_custom_target(copyResources ALL
    COMMAND ${CMAKE_COMMAND} -E copy_directory
    ${CMAKE_SOURCE_DIR}/Resources
    ${CMAKE_CURRENT_BINARY_DIR}/Resources
    COMMENT "Copying resources into the binary folder"
)

FOREACH(LUA_SOURCE IN LISTS LUA_SOURCES)
    add_custom_command(TARGET copyResources POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/${LUA_SOURCE}
        $<TARGET_FILE_DIR:${PROJECT_NAME}>/${LUA_SOURCE})
ENDFOREACH()

add_dependencies(${PROJECT_NAME} copyResources)
