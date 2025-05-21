#include <stdio.h>
#include <glob.h>
#include <unistd.h>

#include "logTest.h"

int main()
{
    printf("this is main().\n");

    logTest();

    return 0;
}

