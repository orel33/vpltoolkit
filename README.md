# VPL Model

## Introduction

Features:
* a public & reusable execution model for VPL
* offline testing using a local *run.sh* script
* ...

## A First Example

Let's consider a VPL activity named *demo*, that you want to develop. In oder to follow our exection model, the *demo* VPL activity must be based on a generic VPL activity (named *vplmodel*), provided here. In other words, the *demo* must inherit from *vplmodel*.

### Parent Activity

Script *vpl_run.sh*:

```bash
#!/bin/bash
VPLMODEL="https://github.com/orel33/vplmodel.git"
MODE="RUN"
git clone $VPLMODEL &> /dev/null
source vplmodel/vplmodel.sh
```

Script *vpl_evaluate.sh*:

```bash
#!/bin/bash
VPLMODEL="https://github.com/orel33/vplmodel.git"
MODE="EVAL"
git clone $VPLMODEL &> /dev/null
source vplmodel/vplmodel.sh
```

### Demo Actvity

Scripts *vpl_run.sh* and *vpl_evaluate.sh*:

```bash
#!/bin/bash
REPOSITORY="https://github.com/orel33/vplmodel.git"
BRANCH="demo"
EXO="demo"
DEBUG=1
VERBOSE=1
vplmodel_start
```

## Execution Model

So, what happens now when you click on the *Run/Eval button* of your VPL Editor in Moodle?

First, it will launch the *vpl_run.sh* (resp. *vpl_evaluate.sh*) script, that you must provide in the VPL Interface > Execution Files.

Typically, this script must provide in any way a new shell script called *vpl_execution*, that will be implicitly launched after *vpl_run.sh* is completed.
 
 (...)

---
aurelien.esnard@u-bordeaux.fr
