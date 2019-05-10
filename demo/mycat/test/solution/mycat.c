#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
    char c;
    while (read(0, &c, 1))
        write(1, &c, 1);
    return EXIT_SUCCESS;
}