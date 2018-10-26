# VPL Toolkit

## Introduction

Features:

* a public & reusable execution model for VPL
* offline testing using a local *run.sh* script
* ...

## Execution Model

So, what happens now when you click on the *Run/Eval button* of your VPL Editor in Moodle (or in *Test Activity*, if you are teacher)?

First, it will launch the *vpl_run.sh* (resp *vpl_evaluate.sh*) script, that you must provide in the VPL Interface > Execution Files.

Typically, this script must provide in any way a new shell script called *vpl_execution*, that will be implicitly launched after *vpl_run.sh* (resp *vpl_evaluate.sh*) is completed.

At this stage, ...

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

## Hello World

Let's consider a VPL activity named *hello*, that you want to develop.



## TODO

* use the same docker environment as the one provided by Moodle @ University of Bordeaux

---
aurelien.esnard@u-bordeaux.fr
