# FROM debian:latest
FROM gblin/minivpl
MAINTAINER Aurelien Esnard <aurelien.esnard@u-bordeaux.fr>

WORKDIR /home/docker
# WORKDIR /tmp/
ARG DEBIAN_FRONTEND=noninteractive

# upgrade in debian testing (with unstable as )
# COPY sources.list /etc/apt/
# COPY preferences /etc/apt/preferences.d/
RUN apt-get update
RUN apt-get install -yq apt-utils apt-file gdebi
# RUN apt-get install -yq apt-show-versions


### Packages used by gblin/minivplc
# RUN install_packages build-essential
# RUN install_packages libc6 libc6-dev libc6-dbg
# RUN install_packages cproto autotools-dev gcc-6 g++-6 dialog ddd xtermcontrol gcc-multilib g++-multilib
# RUN install_packages git shc libsdl-gfx1.2-dev libsdl1.2-dev libsdl-mixer1.2-dev libsdl-ttf2.0-dev libglib2.0-dev libxml2-dev libsdl-image1.2-dev libjs-jquery
# RUN install_packages fonts-tlwg-garuda-ttf subversion indent ldap-utils automake
# RUN install_packages gdb valgrind make cmake

### Set the locale
# ENV LANG en_EN.utf8
RUN apt-get install -yq locales-all
# RUN apt-get install -yq locales
# ARG LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
# RUN locale-gen


# RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales

# RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
#     dpkg-reconfigure --frontend=noninteractive locales && \
#     update-locale LANG=en_US.UTF-8

# ENV LANG en_US.UTF-8 

# editing
RUN apt-get install -yq emacs-nox vim nano

# programming
RUN apt-get install -yq gcc g++ gcc-multilib g++-multilib libc6 libc6-dev libc6-dbg
RUN apt-get install -yq util-linux manpages gdb valgrind
RUN apt-get install -yq cmake cmake-curses-gui cmake-data cmake-doc
RUN apt-get install -yq flex bison
RUN apt-get install -yq libncurses-dev
RUN apt-get install -yq tcl8.5 tcl8.5-dev
RUN apt-get install -yq python3 python3-pip python3-numpy  python3-termcolor
RUN apt-get install -yq python python-pip python-numpy python-pytest python-termcolor
RUN apt-get install -yq pylint pylint3
# RUN apt-get install -yq radon
RUN pip install --upgrade pip
RUN pip3 install --upgrade pip
# RUN pip install numpy scipy scikit-learn matplotlib pandas pytest ipython pytest-cov coverage scan-build

# networking
RUN apt-get install -yq net-tools socat rlwrap wget curl tcpdump
RUN apt-get install -yq python3-scapy python-scapy
RUN apt-get install -yq netcat-openbsd
RUN apt-get install -yq telnet apache2 telnetd ftpd inetutils-inetd

# graphics app
RUN apt-get install -yq xterm x11-apps mesa-utils libgl1-mesa-dev libgl1-mesa-glx
RUN apt-get install -yq libsdl2-dev libsdl2-mixer-dev libsdl2-image-dev libsdl2-gfx-dev libsdl2-ttf-dev libsdl2-net-dev
RUN apt-get install -yq tk8.5 tk8.5-dev graphviz
# RUN apt-get install -yq python3-pygame python-pygame python-pyx
RUN apt-get install -yq python-pygame python-pyx

# X11 & VNC
RUN apt-get install -yq xserver-xorg x11-xserver-utils
RUN apt-get install -yq xfonts-base xfonts-75dpi xfonts-100dpi xfonts-scalable xfonts-cyrillic
RUN apt-get install -yq xvfb x11vnc
RUN apt-get install -yq tightvncserver xtightvncviewer
RUN apt-get install -yq tigervnc-standalone-server tigervnc-common

# Window Manager
RUN apt-get install -yq fluxbox lxterminal lxsession
# RUN apt-get install -yq xmonad xmobar
# RUN apt-get install -yq i3

# remove hardware-accelerated Mesa libraries and install the software-only render
# RUN apt-get install -yq libgl1-mesa-swx11

# BD Web
RUN apt-get install -yq python-psycopg2 python3-psycopg2 python3-flask python-flask
# RUN apt-get install -yq firefox
RUN apt-get install -yq gedit

# misc
RUN apt-get install -yq bash bash-completion
RUN apt-get install -yq tmux screen expect zip unzip git
RUN apt-get install -yq moreutils
RUN apt-get install -yq sudo
RUN apt-get install -yq sbcl
RUN apt-get install -yq bc ncurses-bin
RUN apt-get install -yq ruby
RUN gem install git_fame
RUN apt-get install -yq libreadline-dev libbison-dev flex
RUN apt-get install -yq clang-format

# RUN mkdir -p /run/user/0
# ENV XDG_RUNTIME_DIR /run/user/0

# Init Info
RUN apt-get install -yq automake subversion imagemagick graphviz # firefox-esr
RUN pip3 install Pillow numpy pytest tk requests scspell3k pygame

# clean
RUN apt-get -yq autoremove

# VPL Toolkit
RUN git clone https://github.com/orel33/vpltoolkit.git /vpltoolkit

# EOF
