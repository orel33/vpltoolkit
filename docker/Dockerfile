FROM debian:latest
MAINTAINER Aurelien Esnard <aurelien.esnard@u-bordeaux.fr>
RUN apt-get update
RUN apt-get install -y gcc g++ gcc-multilib g++-multilib libc6 libc6-dev libc6-dbg
RUN apt-get install -y util-linux manpages gdb valgrind
RUN apt-get install -y cmake cmake-curses-gui cmake-data cmake-doc
RUN apt-get install -y flex bison expect
RUN apt-get install -y libncurses-dev
RUN apt-get install -y curl graphviz tcpdump unzip git
RUN apt-get install -y tcl8.5 tk8.5 tcl8.5-dev tk8.5-dev
RUN apt-get install -y python3 python3-pip python3-numpy python3-scapy
RUN pip3 install pygame
RUN apt-get install -y python python-scapy python-pygame python-numpy python-sklearn python-pytest python-pyx
RUN apt-get install -y libsdl2-dev libsdl2-mixer-dev libsdl2-image-dev libsdl2-gfx-dev libsdl2-ttf-dev libsdl2-net-dev
RUN apt-get install -y qemu qemu-kvm vde2 libattr1 libvirt0 socat rlwrap wget virt-manager libvirt-clients libvirt-daemon-system
# RUN apt-get install -y qemu x11-apps
WORKDIR /home/docker
