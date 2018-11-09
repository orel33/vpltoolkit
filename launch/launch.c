#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

int mysystem(char *s, bool silent)
{
  pid_t pid = fork();

  if (!pid)
  {
    execlp("bash", "bash", "-c", s, NULL);
    exit(EXIT_FAILURE);
  }
  int wstatus;
  waitpid(pid, &wstatus, 0);
  if (WIFEXITED(wstatus))
    return WEXITSTATUS(wstatus);
  else if (WIFSIGNALED(wstatus))
  {
    int sig = WTERMSIG(wstatus);
    if (!silent)
      fprintf(stderr, "%s\n", strsignal(sig));
    return 128 + sig; // bash convention
  }
  return EXIT_FAILURE;
}

void usage(int argc, char *argv[])
{
  fprintf(stderr, "Usage: %s [-s] command\n", argv[0]);
  exit(EXIT_FAILURE);
}

int main(int argc, char *argv[])
{
  bool silent = false;
  char *command = NULL;
  if (argc == 2)
    command = argv[1];
  else if ((argc == 3) && (strcmp(argv[1], "-s") == 0))
  {
    command = argv[2];
    silent = true;
  }
  else
    usage(argc, argv);
  return mysystem(command, silent);
  return EXIT_SUCCESS;
}
