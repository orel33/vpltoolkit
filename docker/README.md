# README.md

The Dockerfile is a Debian Testing system with all packages I need for VPL Toolkit.

## Docker Demo

### Run a simple Docker

```bash
host$ ./run.sh
```

### Run OpenGL Application inside Docker

Here, you need to mount host X11 sockets (/tmp/.X11-unix) and set the DISPLAY correctly.

```bash
host$ ./run-glxgears.sh
```

TODO: add image...

### Run Docker inside Docker

Here, you need to mount Docker binary (/usr/bin/docker) and Docker socket (/var/run/docker.sock)...

```bash
host$ ./run-inside-docker.sh
```

### Run Docker headless using VNC Server

In this case, we do not need to mount host X11 sockets (/tmp/.X11-unix/). Instead, we will launch a *vncserver* (Tight VNC Server), that will create its own X11 display (:5999) and will listen on port 5999 ([vncserver.sh](vncservver.sh)). By default, *vncserver* starts a *FluxBox* window manager with *LXDE* desktop environment. The VNC port is exposed by the Docker container to be accessible by remote VNC client.

```bash
host$ ./run-vncserver.sh
docker$ echo $DISPLAY
:5999
docker$ xterm &
```

Now, open another terminal and connect the VNC server to get the display...

```bash
host$ vncviewer localhost:5999
```

TODO: add image...

### Share your VNC Server with another Docker

To go further, we can share this VNC Server with another Docker... To do this, we simply share the X11 sockets (/tmp/.X11-unix/) using a Docker data volume!

```bash
host$ ./run-vncserver-2.sh
docker-2$ xterm &
```

TODO: add image...

Now, you can see in the VNC Viewer two terminals coming from two differents Docker containers! It also works for a Docker launched inside another Docker...

### To be continued...

---