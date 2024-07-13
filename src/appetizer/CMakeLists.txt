################################################################################
set(src_files
    main.cpp main.h)
add_executable(appetizer ${src_files})
target_link_libraries(appetizer PRIVATE kitchen::saladbar)
################################################################################
