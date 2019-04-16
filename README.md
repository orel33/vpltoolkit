# VPL Toolkit

*FIXME: This README must be updated, because since release 4.0, the toolkit API and the startup strategy has evolved!*

## Introduction

*VPL Toolkit* is a light toolkit to help *teachers* to program [VPL](http://vpl.dis.ulpgc.es/) activity in [Moodle](https://moodle.org/) for their *students*.

Features:

* a public & reusable execution model for VPL
* a toolkit with some basic bash functions
* offline execution

## Execution Model of VPL

What happens when a student clicks on the *Run button* of your VPL Editor in Moodle (or in *Test Activity*, if you are teacher)? First, it will launch the *vpl_run.sh* script, that you must provide in the VPL Interface > Execution Files. Typically, this script must provide in any way a new shell script called *vpl_execution* (or *vpl_wexecution* for graphic session), that will be implicitly launched after *vpl_run.sh* is completed. At this stage, *vpl_execution* calls a teacher-defined script *run.sh*. By default, VPL start *run.sh* in text mode. However, it is alse possible to start a graphic session through a VNC connection by setting the variable *GRAPHIC=1* in *vpl_run.sh*.

Here is an overview of this process for the three different modes: *RUN*, *DEBUG* and *EVAL*.

```text
click RUN button -----> vpl_run.sh --------+                         +---> run.sh
click DEBUG button ---> vpl_debug.sh ------+---> vpl_(w)execution ---+---> debug.sh
click EVAL button ----> vpl_evaluate.sh ---+                         +---> eval.sh
```

To develop a new VPL activity, it is often convenient to launch it offline without the Moodle frontend, using *local* scripts, as follow:

```text
local_run.sh ----------+                         +---> run.sh
local_debug.sh --------+---> vpl_(w)execution ---+---> debug.sh
local_eval.sh ---------+                         +---> eval.sh
```

The *run.sh* (resp. *eval.sh*) script is starting from the $RUNDIR directory, organized as follow:

```text
$RUNDIR
  ├── env.sh              # environment variable for the VPL toolkit
  ├── run.sh              # entry point for RUN mode
  ├── debug.sh            # entry point for DEBUG mode
  ├── eval.sh             # entry point for EVAL mode
  ├── ...                 # ...
  ├── ...                 # all files & directories provided by teacher
  ├── inputs              # all student input files ($VPL_SUBFILES)
  │   └── student.c
  |   └── ...
  ├── download            # download main project and extra dependencies here
  │   └── main/...
  │   └── dep1/...
  │   └── dep2/...
  └── vpltoolkit          # VPL toolkit
      └── start.sh        # startup script
      └── toolkit.sh      # useful bash routines
      └── vpl_execution   # VPL execution script
      └── ...
```

Besides, you will find important VPL files in $HOME, that are useful for VPL execution *online*. For security issues, some of these files are removed at runtime.

```text
$HOME
  ├── env.sh
  ├── vpl_execution
  ├── vpl_run.sh
  ├── vpl_evaluate.sh
  └── ...
```

## Output Format and Assessment

See documentation: http://vpl.dis.ulpgc.es/index.php/support

(...)

Rules:

* in RUN mode, all outputs are visible in a terminal window by students (as a basic shell script)
* in EVAL mode, all outputs in comment window are visible by students (it is the main output window)
* in EVAL mode, all outputs in execution window are only visible by teacher (for debug purpose)

To present outputs and grades properly, we provide several useful bash functions in [toolkit.sh](https://github.com/orel33/vpltoolkit/blob/master/toolkit.sh).

## Examples

### Hello World

Let's consider the example [hello](https://github.com/orel33/vpltoolkit/tree/demo/hello). First, you need to add a new activity  This activity consists of only scripts *run.sh* & *eval.sh* that just print "hello world!" on standard output. 

```bash
#!/bin/bash
echo "hello world!"
```

### Starting with VPL Toolkit

To use the *VPL Toolkit* online, start to copy the following script into *vpl_run.sh* & *vpl_evaluate.sh* of VPL@Moodle. Note that on EVAL mode, the "hello world" message is only visible for teacher in execution window.

```bash
#!/bin/bash
rm -f $0 # for security issue
RUNDIR=$(mktemp -d)
( cd $RUNDIR && git clone "https://github.com/orel33/vpltoolkit.git" &> /dev/null )
source $RUNDIR/vpltoolkit/start.sh
DOWNLOAD "https://github.com/orel33/vpltoolkit.git" "demo" "hello"
START_ONLINE
```

To launch this example *offline*, you need to write a script named *local_run.sh* & *local_evaluate.sh* as follow.

```bash
#!/bin/bash
RUNDIR=$(mktemp -d)
( cd $RUNDIR && git clone "https://github.com/orel33/vpltoolkit.git" &> /dev/null )
source $RUNDIR/vpltoolkit/start.sh
DOWNLOAD "https://github.com/orel33/vpltoolkit.git" "demo" "hello"
START_OFFLINE
```

Or if you prefer, you can use the [local_run.sh](https://github.com/orel33/vpltoolkit/blob/master/local_run.sh) (or [local_evaluate.sh](https://github.com/orel33/vpltoolkit/blob/master/local_evaluate.sh)) provided in this repository.

```bash
$ ./local_run.sh hello
hello world!
```

Using Bash DEBUG mode (set -x).

```bash
$ DEBUG=1 ./local_run.sh hello
+ echo 'hello world!'
hello world!
```

### My Cat

An advanced example is found in the *demo* branch of this repository: see [mycat](https://github.com/orel33/vpltoolkit/tree/demo/mycat). Let's have a look on the *eval.sh* script for instance.

```bash
#!/bin/bash

### initialization
source env.sh || exit 0
source vpltoolkit/toolkit.sh || exit 0
CHECKVERSION "4.0"
CHECKINPUTS
GRADE=0

### copy inputs
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

Here is the *offline* test of this script with an input directory of the solution (grade 100% expected).

```bash
(...)
```

## Docker Support

VPL Toolkit enables to use a docker image since version 3.0. First, you need to create a docker image. Given the following [Dockerfile](docker/Dockerfile), you can build your own Debian-like image and push it on [DockerHub](https://hub.docker.com/).

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

## Documentation

* http://vpl.dis.ulpgc.es/index.php/support

## Changes

### Version 4.0

* complete rewrite of API in toolkit.sh
* improve docker support
* add GRAPHIC option
* add DEBUG mode

### Version 3.0

* add a docker support and an optionnal DOCKER variable to set a docker image

### Version 2.0

* add arguments to START_ONLINE and START_OFFLINE functions
* add foating point calculation of GRADE (using python3)
* add branch 1.0 for version 1.0 and use it when cloning vpltoolkit repository

### Version 1.0

* initial version

### To Do

* update documentation in README.md (details on how to build an exercice: file hierarchy, tests, ...)
* update hello example that should not work since version 2.0
* add unit tests of tookit.sh
* add possibility to enrich env.sh with user-defined variables
* add other DOWNLOAD methods for wget and scp, and the possibility to download several stuffs

---
aurelien.esnard@u-bordeaux.fr
