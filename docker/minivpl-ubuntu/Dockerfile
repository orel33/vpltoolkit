### minivpl docker image based on ubuntu 20.10

FROM gblin/minivpl-ubuntu

WORKDIR /home/docker
ARG DEBIAN_FRONTEND=noninteractive

### apt tools
RUN apt-get update
RUN apt-get install -yq build-essential apt-utils apt-file gdebi

### set locales
RUN apt-get install -yq locales-all
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

### misc tools
RUN apt-get install -yq bash bash-completion tmux screen expect zip unzip
RUN apt-get install -yq dialog xtermcontrol shc indent ldap-utils
RUN apt-get install -yq moreutils bc sudo sbcl graphviz

### editing
RUN apt-get install -yq emacs-nox vim nano

### C/C++ programming
RUN apt-get install -yq gcc g++ gcc-multilib g++-multilib
RUN apt-get install -yq gcc-8 g++-8 libc6 libc6-dev libc6-dbg

### programming tools
RUN apt-get install -yq util-linux manpages gdb valgrind 
RUN apt-get install -yq automake autotools-dev
RUN apt-get install -yq cmake cmake-curses-gui cmake-data cmake-doc
RUN apt-get install -yq git subversion
RUN apt-get install -yq clang-format clang-format-8 clang-format-9 clang-format-10 clang-format-11
RUN apt-get install -yq flex bison libbison-dev
RUN apt-get install -yq ncurses-bin libncurses-dev libreadline-dev
RUN apt-get install -yq tcl8.6 tcl8.6-dev tk8.6 tk8.6-dev
RUN apt-get install -yq ruby
RUN gem install git_fame

### python3
RUN apt-get install -yq python3 python3-pip python3-numpy python3-termcolor pylint3
RUN pip3 install --upgrade pip
RUN apt-get install -yq radon

### networking
RUN apt-get install -yq net-tools socat rlwrap wget curl tcpdump netcat-openbsd telnet
RUN apt-get install -yq apache2 telnetd ftpd inetutils-inetd
RUN apt-get install -yq python3-scapy

# graphics app
RUN apt-get install -yq xterm x11-apps mesa-utils libgl1-mesa-dev libgl1-mesa-glx
RUN apt-get install -yq libsdl2-dev libsdl2-mixer-dev libsdl2-image-dev libsdl2-gfx-dev libsdl2-ttf-dev libsdl2-net-dev
RUN apt-get install -yq python3-pygame python3-pyx

# X11 & VNC
RUN apt-get install -yq xserver-xorg x11-xserver-utils
RUN apt-get install -yq xfonts-base xfonts-75dpi xfonts-100dpi xfonts-scalable xfonts-cyrillic
RUN apt-get install -yq xvfb x11vnc
# RUN apt-get install -yq tightvncserver xtightvncviewer
# RUN apt-get install -yq tigervnc-standalone-server tigervnc-common

# Window Manager
RUN apt-get install -yq fluxbox lxterminal lxsession
# RUN apt-get install -yq xmonad xmobar
# RUN apt-get install -yq i3

# remove hardware-accelerated Mesa libraries and install the software-only render
# RUN apt-get install -yq libgl1-mesa-swx11

### BD Web
RUN apt-get install -yq python3-psycopg2 python3-flask
RUN apt-get install -yq gedit firefox

### Init Info
RUN apt-get install -yq  imagemagick graphviz
RUN pip3 install Pillow numpy pytest tk requests scspell3k pygame

### clean
RUN apt-get -yq autoremove

### VPL Toolkit
RUN git clone https://github.com/orel33/vpltoolkit.git /vpltoolkit

# EOF