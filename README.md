# VPL Toolkit

**FIXME: This README must be updated, because since release 4.0, the toolkit API and the startup strategy has evolved!**

## Introduction

*VPL Toolkit* is a light toolkit to help *teachers* to program [VPL](http://vpl.dis.ulpgc.es/) activity in [Moodle](https://moodle.org/) for their *students*.

Features:

* a public & reusable execution model for VPL
* a toolkit with some basic bash functions
* offline execution

## Execution Model of VPL

What happens when a student clicks on the *Run/Eval button* of your VPL Editor in Moodle (or in *Test Activity*, if you are teacher)?

First, it will launch the *vpl_run.sh* (resp *vpl_evaluate.sh*) script, that you must provide in the VPL Interface > Execution Files. Typically, this script must provide in any way a new shell script called *vpl_execution*, that will be implicitly launched after *vpl_run.sh* (resp *vpl_evaluate.sh*) is completed. At this stage, *vpl_execution* calls a teacher-defined script *run.sh* (resp. *eval.sh*) depending on the execution mode, either RUN or EVAL. Here is an overview of the 

```text
click RUN button --> vpl_run.sh ----------+                    +--> run.sh
                                          |--> vpl_execution --|
click EVAL button --> vpl_evaluate.sh ----+                    +--> eval.sh
```

To develop a new VPL activity, it is often convenient to launch it offline without the Moodle frontend, using *local* scripts, as follow:

```text
local_run.sh ----------+                    +--> run.sh
                       |--> vpl_execution --|
local_eval.sh ---------+                    +--> eval.sh
```

The *run.sh* (resp. *eval.sh*) script is starting from the $RUNDIR directory, organized as follow:

```text
$RUNDIR
  ├── env.sh              # environment variable for the VPL toolkit
  ├── run.sh              # entry point for RUN mode
  ├── eval.sh             # entry point for EVAL mode
  ├── ...                 # ...
  ├── ...                 # all files & directories provided by teacher
  ├── inputs              # all student input files ($VPL_SUBFILES)
  │   └── student.c
  |   └── ...
  └── vpltoolkit          # VPL toolkit
      └── start.sh        # startup script
      └── toolkit.sh      # useful bash routines
      └── vpl_execution
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
source env.sh
source vpltoolkit/toolkit.sh
[ ! "$RUNDIR" = "$PWD" ] && echo "⚠ RUNDIR is not set correctly!" && exit 0
CHECKINPUTS
cp inputs/mycat.c .
GRADE=0

### compilation
TITLE "COMPILATION"
CFLAGS="-std=c99 -Wall"
WFLAGS="-Wl,--wrap=system"
TRACE "gcc $CFLAGS $WFLAGS mycat.c -o mycat |& tee warnings"
[ $? -ne 0 ] && MALUS "Compilation" X "errors"
[ -s warnings ] && MALUS "Compilation" 20 "warnings"
[ -x mycat ] && BONUS "Linking" 30

### execution
TITLE "EXECUTION"
TRACE "echo \"abcdef\" > mycat.in"
TRACE "cat mycat.in | ./mycat > mycat.out"
[ $? -ne 0 ] && MALUS "Return" 10 "bad status"
TRACE "diff -q mycat.in mycat.out"
EVAL "Program output" 70 0 "valid" "invalid"
EXIT
```

Here is the *offline* test of this script with an input directory of the solution (grade 100% expected).

```bash
$ git checkout demo
$ ./local_eval.sh mycat mycat/test/solution
Comment :=>>-COMPILATION
Trace :=>>$ gcc -std=c99 -Wall -Wl,--wrap=system mycat.c -o mycat |& tee warnings
Status :=>> 0
Comment :=>>✓ Linking: success. [+30]
Comment :=>>-EXECUTION
Trace :=>>$ echo "abcdef" > mycat.in
Status :=>> 0
Trace :=>>$ cat mycat.in | ./mycat > mycat.out
Status :=>> 0
Trace :=>>$ diff -q mycat.in mycat.out
Status :=>> 0
Comment :=>>✓ Program output: valid [+70]
Comment :=>>
Comment :=>>-GRADE
Comment :=>>100 / 100
Grade :=>> 100
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
$ docker push orel33/mydebian:latest
```

## Documentation

* http://vpl.dis.ulpgc.es/index.php/support

## Changes

### Version 4.0

* complete rewrite of API in toolkit.sh
* improve docker support
* add GRAPHIC option

### Version 3.0

* add a docker support and an optionnal DOCKER variable to set a docker image

### Version 2.0

* add arguments to START_ONLINE and START_OFFLINE functions
* add foating point calculation of GRADE (using python3)
* add branch 1.0 for version 1.0 and use it when cloning vpltoolkit repository

### Version 1.0

* initial version

### To Do

* add the possibility for local/offline run & eval to clone local repository instead of remote one
* improve version management
* add script to launch all local tests offline and compare them against an expected grade
* use an optional execution file *env.sh* (provided by teacher at Moodle)
* add other DOWNLOAD methods for wget and scp
* update documentation in README.md (details on how to build an exercice: file hierarchy, tests, ...)
* update hello example that should not work since version 2.0
* add timeout in (R)TRACE/(R)EVAL/ ou use timeout command???

---
aurelien.esnard@u-bordeaux.fr
