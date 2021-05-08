# VPL Toolkit

## Introduction

*VPL Toolkit* is a light toolkit to help *teachers* to program
[VPL](http://vpl.dis.ulpgc.es/) activity in [Moodle](https://moodle.org/) for
their *students*.

Features:

* a public & reusable execution model for VPL
* a toolkit with some basic bash functions
* offline execution using a local script
* execution of VPL scripts within docker containers (both online & offline)

A short tutorial is available [here](misc/talk-grenoble-2019.md).

## Execution Model of VPL

What happens when a student clicks on the *Run button* of your VPL Editor in Moodle (or in *Test Activity*, if you are teacher)? First, it will launch the *vpl_run.sh* script, that you must provide in the VPL Interface > Execution Files. Typically, this script must provide in any way a new shell script called *vpl_execution* (or *vpl_wexecution* for graphic session), that will be implicitly launched after *vpl_run.sh* is completed. At this stage, *vpl_execution* calls a teacher-defined entrypoint script (default, *ENTRYPOINT="run.sh"*). By default, VPL starts in text mode. However, it is also possible to start a graphic session through a VNC connection by setting the variable *GRAPHIC=1* in *vpl_run.sh*.

VPL provides three different execution modes:

* RUN: ...
* DEBUG: ...
* EVAL: ...

Here is an overview of this process for the three different modes:

```text
click RUN button -----> vpl_run.sh --------+
click DEBUG button ---> vpl_debug.sh ------+---> vpl_(w)execution ---+---> run.sh
click EVAL button ----> vpl_evaluate.sh ---+
```

To develop a new VPL activity, it is often convenient to launch VPL scripts offline without the Moodle frontend, using the *local.sh* script, as follow:

```text
local.sh [...] --------+---> vpl_(w)execution ---+---> run.sh
```

The entrypoint script (*run.sh* by default) is starting from the *$RUNDIR* directory, organized as follow:

```text
$RUNDIR
  ├── env.sh              # environment variable for the VPL toolkit
  ├── run.sh              # default entrypoint script
  ├── ...                 # ...
  ├── ...                 # all files & directories provided by teacher
  ├── inputs              # all student input files ($VPL_SUBFILES)
  │   └── student.c
  |   └── ...
  └── vpltoolkit          # VPL toolkit
      └── start.sh        # startup script
      └── toolkit.sh      # useful bash routines
      └── vpl_execution   # VPL execution script
      └── ...
```

Besides, you will find important VPL files in $HOME, that are useful for VPL execution *online*. For security issues, some of these files are removed at runtime. For practical reasons, some of these files are also copied into the *RUNDIR* directory, as for instance *vpl_environment.sh*.

```text
$HOME
  ├── env.sh
  ├── vpl_execution
  ├── vpl_run.sh
  ├── vpl_evaluate.sh
  ├── vpl_environment.sh
  └── ...
```

## Output Format and Assessment

See documentation: http://vpl.dis.ulpgc.es/index.php/support

Keep in mind this rules, when using VPL online:

* in RUN mode, all outputs are visible in a terminal window by students (as a basic shell script)
* in EVAL mode, all outputs in comment window are visible by students (it is the main output window)
* in EVAL mode, all outputs in execution window are only visible by teacher (for debug purpose)

## Examples

### Hello World

Let's consider the example [hello](https://github.com/orel33/vpltoolkit/tree/master/demo/hello). The entrypoint of a VPL activity in our framework is just simple bash script *run.sh* available on Internet through a GIT repository.
In this dummy example, our script just prints "hello world!" on standard output.

```bash
#!/bin/bash
echo "hello world!"
```

To use the *VPL Toolkit* with Moodle online, you need to save this script as *vpl_run.sh* (resp. *vpl_evaluate.sh* or *vpl_debug.sh*).

```bash
#!/bin/bash
rm -f $0 # for security issue
RUNDIR=$(mktemp -d)
DOCKER="orel33/mydebian:latest" # a docker registered on docker hub
( cd $RUNDIR && git clone "https://github.com/orel33/vpltoolkit.git" -b "4.0" &> /dev/null )
[ ! $? -eq 0 ] && echo "⚠ Fail to download VPL Toolkit!" && exit 0
source $RUNDIR/vpltoolkit/start.sh || exit 0
GITUSER="toto"
GITPW="secret"
GITREPOSITORY="services.emi.u-bordeaux.fr/projet/git/myrepository"
GITBRANCH="master"
GITSUBDIR="exo1"
DOWNLOAD "https://$GITUSER:$GITPW@$GITREPOSITORY" "$GITBRANCH" "$GITSUBDIR"
START_ONLINE "arg0" "arg1"
```

For instance:

```bash
#!/bin/bash
RUNDIR=$(mktemp -d)
DOCKER="orel33/mydebian:latest"
( cd $RUNDIR && git clone "https://github.com/orel33/vpltoolkit.git" -b "4.0" &> /dev/null )
source $RUNDIR/vpltoolkit/start.sh
DOWNLOAD "https://github.com/orel33/vpltoolkit.git" "master" "demo/hello"
START_ONLINE
```

To launch this example *offline* in *RUN* mode, you have to use the script [local.sh](https://github.com/orel33/vpltoolkit/blob/master/local.sh) provided by VPL Toolkit.

```bash
$ ./local.sh -m RUN -r "https://github.com/orel33/vpltoolkit.git" -s demo/hello
hello world!
```

### My Cat

Another example is a C programming exercice of the Unix *cat* command: [mycat](https://github.com/orel33/vpltoolkit/tree/master/demo/mycat). The student must implement this command in a file named *mycat.c* (available in the inputs/ directory). Let's have a look on the entrypoint script *run.sh*.

```bash
#!/bin/bash

### initialization
source env.sh || exit 0
source vpltoolkit/toolkit.sh || exit 0
CHECKVERSION "4.0"
CHECKDOCKER "orel33/mydebian:latest"
GRADE=0

### student inputs
[ ! -f inputs/mycat.c ] && ERROR "Input file mycat.c expected but not found!" && EXIT_GRADE 0
cp inputs/mycat.c .

### compilation
TITLE "COMPILATION"
CFLAGS="-std=c99 -Wall"
WFLAGS="-Wl,--wrap=system"
TRACE "gcc $CFLAGS $WFLAGS mycat.c -o mycat |& tee warnings"
EVALKO $? "compilation" 0 "errors" && EXIT_GRADE 0
[ -x mycat ] && EVALOK $? "compilation" 30 "success"
[ -s warnings ] && EVALKO 1 "compilation" -10 "warnings"

### execution
TITLE "EXECUTION"
TRACE_TEACHER "echo \"abcdef\" > mycat.in"
TRACE_TEACHER "cat mycat.in | ./mycat > mycat.out"
EVAL $? "run mycat" 10 0
TRACE_TEACHER "diff -q mycat.in mycat.out"
EVAL $? "test mycat" 60 0

EXIT_GRADE
```

Here is way to launch this example *offline*, with an input directory of the solution (grade 100% expected).

```bash
$ ./local.sh -m RUN -d "orel33/mydebian:latest" -r "https://github.com/orel33/vpltoolkit.git" -s demo/mycat -i demo/mycat/test/solution
Run Docker orel33/mydebian:latest.
######### COMPILATION ##########
✔️ compilation: success (success) [+30.00%]
######### EXECUTION ##########
✔️ run mycat: success  [+10.00%]
✔️ test mycat: success  [+60.00%]
Docker orel33/mydebian:latest terminated.
```

## VPL Toolkit API

To present outputs and grades properly in different modes, we provide several useful bash functions in [toolkit.sh](https://github.com/orel33/vpltoolkit/blob/master/toolkit.sh).

```bash
function ECHOBLUE()
function ECHOGREEN()
function ECHORED()
function ECHOYELLOW()
function ECHO()
function ECHO_TEACHER()
function ECHO_DEBUG()
function PRE()
function WARNING()
function ERROR()
function CRASH()
function INFO()
function PRINTOK()
function PRINTKO()
function TITLE()
function TITLE_TEACHER()
function CAT()
function CAT_TEACHER()
function EXEC()
function STRSTATUS()
function TRACE()
function TRACE_TEACHER()
function WAIT()
function PYCOMPUTE()
function UPDATE_GRADE()
function EVALOK()
function EVALKO()
function EVAL()
function EXIT_GRADE()
function CHECKVERSION()
function CHECKDOCKER()
function CHECKFILES()
function CHECKPROGRAMS()
```

TODO: Explain API guideline and write the documentation... In the meantime, read *toolkit.sh*...


## Use VPL Toolkit on localhost: local.sh

```
Usage: ./local.sh <download> [options] <...>
Start VPL Toolkit on localhost.
select <download> method:
    -l <localdir>: copy teacher files from local directory into <rundir>
    -r <repository>: download teacher files from remote git repository
    -w <url>: download teacher zip archive from remote web site
[options]:
    -L: use local version of VPL Toolkit
    -n <version> : set the branch/version of VPL Toolkit to use (default master)
    -m <mode>: set execution mode to RUN, DEBUG or EVAL (default RUN)
    -g : enable graphic mode (default no)
    -d <docker> : set docker image to be used (default, no docker)
    -u <dockeruser>: set docker user (-d required)
    -b <branch>: checkout a branch from git repository (default master, -r required)
    -p <password>: unzip teacher archive using a password (-w required)
    -s <subdir>: only download teacher files from subdir into <rundir>
    -e <entrypoint>: entrypoint shell script (default run.sh)
    -i <inputdir>: student input directory
    -v: enable verbose mode (default no)
    -D: enable debug mode (default no)
    -h: help
<...>: extra arguments passed to START routine in VPL Toolkit
```

For instance, let's run *hello world* example from `https://github.com/orel33/vpltoolkit.git` repository and subdir `demo/hello` in *RUN* mode using Docker *orel33/mydebian:latest*:

```bash
$ ./local.sh -m RUN -d "orel33/mydebian:latest" -l . -s demo/hello
Run Docker orel33/mydebian:latest.
hello world!
Docker orel33/mydebian:latest terminated.
```

Instead of using local files (option -l), you can use a remote GIT repository as follows:

```bash
$ ./local.sh -m RUN -d "orel33/mydebian:latest" -r "https://github.com/orel33/vpltoolkit.git" -s demo/hello
```

## Docker Support

VPL Toolkit enables to use a docker image since version 3.0. First, you need to create a docker image. Given the following [Dockerfile](docker/Dockerfile), you can build your own Debian-like image and push it on [DockerHub](https://hub.docker.com/).

Note: you need to base your DockerFile on gblin/minivpl to have the server part of the VPL inside the image.

```bash
# build image
$ docker build -t "orel33/mydebian:latest" .
# test it
$ docker run -i -t orel33/mydebian /bin/bash
# login (need to be registered)
$ docker login
# push image
$ docker push "orel33/mydebian:latest"
```

To pull this docker image:

```bash
$ docker pull orel33/mydebian:latest
```

Then, you just need to set the *DOCKER* variable in your vplbdx.cfg file. For instance:

```
DOCKER=orel33/mydebian:latest
```

## Documentation

* http://vpl.dis.ulpgc.es/index.php/support

## Changes

### Version 4.0

* MacOS portability
* add *local.sh* script to start VPL Toolkit on localhost
* complete rewrite of API in *toolkit.sh*
* improve docker support
* add GRAPHIC=0|1 option
* add DEBUG=0|1 option
* add DOCKERUSER option to enable docker image with regular user (no root)

### Version 3.0

* add a docker support and an optionnal DOCKER variable to set a docker image

### Version 2.0

* add arguments to START_ONLINE and START_OFFLINE functions
* add foating point calculation of GRADE (using python3)
* add branch 1.0 for version 1.0 and use it when cloning vpltoolkit repository

### Version 1.0

* initial version

### To Do

* update documentation in README.md (API in toolkit.sh)
* update unit tests of tookit.sh
* add possibility to enrich env.sh with user-defined variables
* use `set -o piepfail ; cmd1 | cmd2` to improve `TRACE()` implementation in `toolkit.sh`
* add memory limit option in TRACE routine (use `ulimit -v MAXMEM` in subshell)
* etc.

### Bugs

* bug using `tput`
* `launch.sh` seems to bo broken in current version...

---
aurelien.esnard@u-bordeaux.fr
