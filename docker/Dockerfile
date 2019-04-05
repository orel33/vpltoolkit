FROM debian:latest
MAINTAINER Aurelien Esnard <aurelien.esnard@u-bordeaux.fr>
WORKDIR /home/docker
ARG DEBIAN_FRONTEND=noninteractive

# upgrade in debian testing
COPY sources.list /etc/apt/
RUN apt-get update
RUN apt-get install -y apt-utils apt-file

# editing
RUN apt-get install -y emacs-nox vim nano

# misc
RUN apt-get install -y locales-all tmux screen expect unzip git

# programming
RUN apt-get install -y gcc g++ gcc-multilib g++-multilib libc6 libc6-dev libc6-dbg
RUN apt-get install -y util-linux manpages gdb valgrind
RUN apt-get install -y cmake cmake-curses-gui cmake-data cmake-doc
RUN apt-get install -y flex bison
RUN apt-get install -y libncurses-dev
RUN apt-get install -y tcl8.5 tcl8.5-dev
RUN apt-get install -y python3 python3-pip python3-numpy 
RUN apt-get install -y python python-pip python-numpy  python-pytest

# networking
RUN apt-get install -y net-tools socat rlwrap wget curl tcpdump
RUN apt-get install -y python3-scapy python-scapy

# graphics app
RUN apt-get install -y xterm x11-apps mesa-utils libgl1-mesa-dev libgl1-mesa-glx
RUN apt-get install -y libsdl2-dev libsdl2-mixer-dev libsdl2-image-dev libsdl2-gfx-dev libsdl2-ttf-dev libsdl2-net-dev
RUN apt-get install -y tk8.5 tk8.5-dev graphviz
RUN apt-get install -y python3-pygame python-pygame python-pyx

# vnc support
RUN apt-get install -y tightvncserver fluxbox lxterminal lxsession x11vnc gvncviewer

# clean
RUN apt-get -y autoremove

# EOF