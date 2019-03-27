FROM debian:latest
MAINTAINER Aurelien Esnard <aurelien.esnard@u-bordeaux.fr>
WORKDIR /home/docker
ARG DEBIAN_FRONTEND=noninteractive

# upgrade in debian testing
COPY sources.list /etc/apt/
RUN apt-get update && apt-get install -y apt-utils

# editing
RUN apt-get install -y emacs-nox vim nano
# misc
RUN apt-get install -y locales-all tmux screen expect
# programming
RUN apt-get install -y gcc g++ gcc-multilib g++-multilib libc6 libc6-dev libc6-dbg
RUN apt-get install -y util-linux manpages gdb valgrind
RUN apt-get install -y cmake cmake-curses-gui cmake-data cmake-doc
RUN apt-get install -y flex bison
RUN apt-get install -y libncurses-dev
RUN apt-get install -y tcl8.5 tk8.5 tcl8.5-dev tk8.5-dev
RUN apt-get install -y python3 python3-pip python3-numpy python3-scapy python3-pygame
RUN apt-get install -y python python-scapy python-pygame python-numpy python-sklearn python-pytest python-pyx
RUN apt-get install -y libsdl2-dev libsdl2-mixer-dev libsdl2-image-dev libsdl2-gfx-dev libsdl2-ttf-dev libsdl2-net-dev
# networking and qemu 
RUN apt-get install -y linux-image-amd64
RUN apt-get install -y socat rlwrap wget curl graphviz tcpdump unzip git
RUN apt-get install -y qemu qemu-kvm vde2 libattr1 libattr1-dev
RUN apt-get install -y libvirt0 virt-manager libvirt-clients libvirt-daemon-system
RUN apt-get install -y libguestfs-tools
RUN apt-get install -y fuse fuseext2
