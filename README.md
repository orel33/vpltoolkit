# VPL Model

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
  ├── env.sh
  ├── inputs                   # all input files submitted by VPL by student ($VPL_SUBFILES)
  │   └── student.c
  |   └── ...
  ├── download                 # all files provided by teacher to perform evaluation
  |    ├── run.sh              # <-- entry point
  |    ├── solution.c
  │    └── ...
  └── vplmodel                 # VPL toolkit
      └── toolkit.sh
      └── vpl_execution
      └── ...
```

Besides, you will find some copy of files in $HOME, that are useful for VPL boot for *online* execution only.

```text
$HOME
  ├── env.sh
  ├── vpl_execution
  └── ...
```

## Hello World

Let's consider a VPL activity named *hello*, that you want to develop. In oder to follow our exection model, the *hello* VPL activity must be based on a generic VPL activity (named *vplmodel*), provided here. In other words, the *hello* must inherit from *vplmodel*.



---
aurelien.esnard@u-bordeaux.fr
