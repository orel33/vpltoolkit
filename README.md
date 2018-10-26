# VPL Toolkit

## Introduction

*VPL Toolkit* is a light toolkit to help *teachers* to program [VPL](http://vpl.dis.ulpgc.es/) activity in [Moodle](https://moodle.org/) for their *students*.

Features:

* a public & reusable execution model for VPL
* a toolkit with some basic bash functions
* offline execution

## Execution Model

What happens when you click on the *Run/Eval button* of your VPL Editor in Moodle (or in *Test Activity*, if you are teacher)?

First, it will launch the *vpl_run.sh* (resp *vpl_evaluate.sh*) script, that you must provide in the VPL Interface > Execution Files. Typically, this script must provide in any way a new shell script called *vpl_execution*, that will be implicitly launched after *vpl_run.sh* (resp *vpl_evaluate.sh*) is completed.

At this stage, we introduce a unique script *run.sh* ...

```text
click RUN button --> vpl_run.sh ----------+
                                          |--> vpl_execution --> run.sh
click EVAL button --> vpl_evaluate.sh ----+
```

To develop a new VPL activity, it is often convenient to launch it offline without the Moodle frontend, using *local* scripts, as follow:

```text
local_run.sh ----------+
                       |--> vpl_execution --> run.sh
local_evaluate.sh -----+
```

The *run.sh* script is starting from the $RUNDIR directory, organized as follow:

```text
$RUNDIR
  ├── env.sh              # environment variable for the VPL toolkit
  ├── run.sh              # entry point
  ├── ...                 # all files provided by teacher...
  ├── inputs              # all input files submitted by VPL by student ($VPL_SUBFILES)
  │   └── student.c
  |   └── ...
  └── vpltoolkit          # VPL toolkit
      └── toolkit.sh
      └── vpl_execution
      └── ...
```

Besides, you will find two important files in $HOME, that are useful for VPL execution *online*.

```text
$HOME
  ├── env.sh
  └── vpl_execution
```

## Examples 

### Hello World

Let's consider the example [hello](https://github.com/orel33/vplmodel/tree/demo/hello). This activity is made of a single script *run.sh* that just print "hello world!".

```bash
#!/bin/bash
echo "hello world!"
```

To use the *VPL Toolkit*, start to copy the following script into *vpl_run.sh* & *vpl_evaluate.sh* of VPL@Moodle.

```bash
#!/bin/bash
VPLMODEL="https://github.com/orel33/vplmodel.git"
RUNDIR=$(mktemp -d)
( cd $RUNDIR && git clone $VPLMODEL &> /dev/null )
source $RUNDIR/vplmodel/toolkit.sh
EXO="hello"
DOWNLOAD "https://github.com/orel33/vplmodel.git" "demo" $EXO
START_ONLINE
```

To launch this example *offline*, you nee to write a script named *local_run.sh* & *local_evaluate.sh* as follow.

```bash
#!/bin/bash
VPLMODEL="https://github.com/orel33/vplmodel.git"
RUNDIR=$(mktemp -d)
( cd $RUNDIR && git clone $VPLMODEL &> /dev/null )
source $RUNDIR/vplmodel/toolkit.sh
EXO="hello"
DOWNLOAD "https://github.com/orel33/vplmodel.git" "demo" $EXO
START_OFFLINE
```

### My Cat

(...)

## TODO

* add an option to use a docker environment for *offline* execution

---
aurelien.esnard@u-bordeaux.fr
