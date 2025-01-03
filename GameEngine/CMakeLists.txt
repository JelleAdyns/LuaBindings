project(EngineLibrary)

file(GLOB SRC
     "*.h"
     "*.cpp"
)

add_library(${PROJECT_NAME} STATIC ${SRC})

set_target_properties(${PROJECT_NAME} PROPERTIES WIN32_EXECUTABLE YES)

target_include_directories(${PROJECT_NAME}
    PUBLIC "./"
)
