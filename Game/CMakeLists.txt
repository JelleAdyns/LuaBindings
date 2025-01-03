project(GameName)

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
)
FetchContent_MakeAvailable(lua)


# Fetch SOL2
# ++++++++++
FetchContent_Declare(
    sol2
    URL https://github.com/ThePhD/sol2/archive/refs/tags/v3.3.0.tar.gz
)
FetchContent_MakeAvailable(sol2)
target_link_libraries(${PROJECT_NAME} PRIVATE lua::lua sol2)

message(STATUS "BINARY DIR: ${CMAKE_CURRENT_BINARY_DIR}")
add_custom_command(
        TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different
                ${CMAKE_SOURCE_DIR}/Scripts
                ${CMAKE_CURRENT_BINARY_DIR}/Scripts
)
