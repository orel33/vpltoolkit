FROM debian:latest
MAINTAINER Aurelien Esnard <aurelien.esnard@u-bordeaux.fr>
WORKDIR /home/docker
ARG DEBIAN_FRONTEND=noninteractive
# ENV LANG en_EN.utf8 

# upgrade in debian testing (with unstable as )
COPY sources.list /etc/apt/
COPY preferences /etc/apt/preferences.d/
RUN apt-get update
RUN apt-get install -y apt-utils apt-file gdebi
# RUN apt-get install -y apt-show-versions

# editing
RUN apt-get install -y emacs-nox vim nano

# programming
RUN apt-get install -y gcc g++ gcc-multilib g++-multilib libc6 libc6-dev libc6-dbg
RUN apt-get install -y util-linux manpages gdb valgrind
RUN apt-get install -y cmake cmake-curses-gui cmake-data cmake-doc
RUN apt-get install -y flex bison
RUN apt-get install -y libncurses-dev
RUN apt-get install -y tcl8.5 tcl8.5-dev
RUN apt-get install -y python3 python3-pip python3-numpy  python3-termcolor
RUN apt-get install -y python python-pip python-numpy python-pytest python-termcolor
RUN apt-get install -y radon

# networking
RUN apt-get install -y net-tools socat rlwrap wget curl tcpdump
RUN apt-get install -y python3-scapy python-scapy
RUN apt-get install -y netcat-openbsd

# graphics app
RUN apt-get install -y xterm x11-apps mesa-utils libgl1-mesa-dev libgl1-mesa-glx
RUN apt-get install -y libsdl2-dev libsdl2-mixer-dev libsdl2-image-dev libsdl2-gfx-dev libsdl2-ttf-dev libsdl2-net-dev
RUN apt-get install -y tk8.5 tk8.5-dev graphviz
RUN apt-get install -y python3-pygame python-pygame python-pyx

# X11 & VNC
RUN apt-get install -y xserver-xorg x11-xserver-utils
RUN apt-get install -y xfonts-base xfonts-75dpi xfonts-100dpi xfonts-scalable xfonts-cyrillic
RUN apt-get install -y xvfb x11vnc
RUN apt-get install -y tightvncserver xtightvncviewer
RUN apt-get install -y tigervnc-standalone-server tigervnc-common

# Window Manager
RUN apt-get install -y fluxbox lxterminal lxsession 
# RUN apt-get install -y xmonad xmobar
# RUN apt-get install -y i3

# remove hardware-accelerated Mesa libraries and install the software-only render
# RUN apt-get install -y libgl1-mesa-swx11 

# BD Web
RUN apt-get install -y python-psycopg2 python3-psycopg2 python3-flask python-flask
RUN apt-get install -y firefox

# misc
RUN apt-get install -y bash bash-completion
RUN apt-get install -y locales-all tmux screen expect unzip git
RUN apt-get install -y moreutils
RUN apt-get install -y gedit
RUN apt-get install -y sudo

# clean
RUN apt-get -y autoremove

# user toto
# RUN useradd -ms /bin/bash toto
# RUN echo 'toto ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
# RUN gpasswd -a toto sudo
# # RUN sudo bash -c 'echo -e "toto\ntoto\n" | passwd toto'
# WORKDIR /home/toto
# ENV USER toto
# USER toto

# VS Code
# RUN wget -q "https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable" -O /tmp/vscode.deb && sudo gdebi --n /tmp/vscode.deb
# RUN wget -q "https://raw.githubusercontent.com/orel33/vscode/master/extensions.sh" -O /tmp/extensions.sh && bash /tmp/extensions.sh


# EOF