# VPL Toolkit

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
  ├── ...                 # all files provided by teacher...
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

An advanced example is found in the *demo* branch of this repository: see [mycat](https://github.com/orel33/vpltoolkit/tree/demo/mycat).


```bash
$ ./local_run.sh hello
hello world!
```

## Documentation

* http://vpl.dis.ulpgc.es/index.php/support

## TODO

* add an option to use a docker environment for *offline* execution (and maybe *online*)
* use an optional execution file *env.sh* (provided by teacher at Moodle)
* add other DOWNLOAD methods for wget and scp

---
aurelien.esnard@u-bordeaux.fr
