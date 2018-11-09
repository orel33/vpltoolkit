#include <stdio.h>

int main(void) {
  printf("I will segfault!\n");
  *((int*)0)=0;
  return 0;
}
