#include <stdio.h>

int main(void) {
  printf("stdout: I will segfault!\n");
  fprintf(stderr, "stderr: Yeah... It comes now!\n");
  *((int*)0)=0;
  return 0;
}
