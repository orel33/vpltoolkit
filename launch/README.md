# README

## Simple Launcher

The idea is to control the message returned by bash script, when a signal (e.g. SEGV) killed a child command...

Here is an example of a script (*bad.sh*) that launch the *segfault.c* program, that leads to a SEGV signal.

```bash
$ ./segfault
i will segfault
./bad.sh: line 5:  8436 Segmentation fault      ./segfault
return 139
```

To avoid printing this ugly message, my solution is to use a launcher program (see *launch.c*) that replaces bash for this. Lets run *good.sh* script as an example.

```bash
# silent mode
$ ./launch -s "./segfault"
return 139

# regular mode
$ ./launch "./segfault"
I will segfault!
Segmentation fault
return 139
```

## An Alternative Solution

```bash
( stdbuf -oL ./a.out &> out ) | :
RET=${PIPESTATUS[0]}
cat out
echo $RET
```

Nevertheless, it needs to be improve by piping the output in a *fifo* instead of using a temporaily file...
