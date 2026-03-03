cmake_minimum_required(VERSION 2.8.8)

project(GETIMAGENAME C)

set_property(DIRECTORY PROPERTY COMPILE_DEFINITIONS _GNU_SOURCE)

find_package(PkgConfig REQUIRED QUIET)


add_executable(mapped_email
  mapped_email.c
)
set_property(TARGET mapped_email PROPERTY COMPILE_FLAGS "-std=c99 -Wall")
#set_property(TARGET mapped_email PROPERTY LINK_FLAGS "")
target_link_libraries(mapped_email
    m
)

install(TARGETS mapped_email RUNTIME DESTINATION sbin)
