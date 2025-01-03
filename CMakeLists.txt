cmake_minimum_required(VERSION 3.20)
project(SE_Finals_Project)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_compile_options(/W3 /WX)

add_compile_definitions(-DUNICODE -D_UNICODE)

add_subdirectory(GameEngine)
add_subdirectory(Game)


