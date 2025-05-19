#Version
CMAKE_MINIMUM_REQUIRED(VERSION 3.2)

#Solutin
PROJECT(Solution)

function(MY_PARSE)

    set(options ADULT)
    set(oneValueArgs NAME AGE)
    set(multiValueArgs "SCORE;OTHER")

    cmake_parse_arguments(STUDENT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    # 通过 prefix_参数名: 例如 STUDENT_ADULT
    message("isadult  = ${STUDENT_ADULT}")
    message("name  = ${STUDENT_NAME}")
    message("age  = ${STUDENT_AGE}")
    message("score  = ${STUDENT_SCORE}")
    message("other  = ${STUDENT_OTHER}")

endfunction()

MY_PARSE(ADULT NAME zhangsan AGE 20 SCORE 100 200 300 400 500 OTHER 1 2 3)