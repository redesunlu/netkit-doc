#!/bin/bash

set -e

NETKIT_REPO=http://www.unlu.edu.ar/~tyr/netkit
NETKIT_LABS=http://wiki.netkit.org/netkit-labs
NETKIT_CORE=netkit-ng-core-32-3.0.4-TYR.tar.bz2
NETKIT_FS=netkit-ng-filesystem-i386-F7.0-0.1.4-TYR.tar.bz2
NETKIT_KERNEL=netkit-ng-kernel-i386-K3.2-0.1.4-TYR.tar.bz2
NETKIT_DIR=~/netkit
LABS_GITHUB_REPO=https://raw.githubusercontent.com/redesunlu/netkit-labs
LABS_GITHUB="netkit-lab_quagga-TYR netkit-lab_rip-TYR"
LABS_UNLU="netkit-lab_dns-TYR netkit-lab_email-TYR netkit-lab_proxy-TYR"
LABS_BASIC="netkit-lab_arp"
LABS_APPL="netkit-lab_webserver netkit-lab_nat"
REQUIRED_PACKAGES="bzip2 ca-certificates lsof uml-utilities xterm gnome-terminal wireshark tshark tcpdump"

# verify if we have wget
test -x /usr/bin/wget || run_as_root apt-get install wget

# verify that wget supports show-progress
SHOW_PROGRESS=""
if wget --help | grep -qF "show-progress"; then
    SHOW_PROGRESS="--show-progress"
fi


run_as_root () {
    # run command as root with su or sudo
    if grep -qF "ID=debian" /etc/os-release; then
        echo "Por favor ingrese la clave de root para continuar con la instalación."
        su root -m -c "$*" root
    else
        echo "Por favor ingrese su clave para continuar con la instalación."
        sudo $*
    fi
}

show_intro () {
    echo "==================================================================="
    echo "   Esta secuencia de comandos instalará Netkit-NG en este equipo."
    echo "   La instalación requiere al menos 2 GB de espacio disponible."
    echo "   Todos los archivos se almacenarán en el directorio $NETKIT_DIR"
    echo
    echo "   Verifique la documentación disponible en"
    echo "      https://github.com/redesunlu/netkit-doc"
    echo "==================================================================="
    echo
}

verify_locale_utf8 () {
    # verify that the locale is utf8, or gnome-terminal won't work
    if [[ ! "$LANG" =~ (utf|UTF)-?8$ ]]; then
        # force locale es_AR.UTF-8
        echo "ERROR: Su sistema debe utilizar un lenguaje con codificación UTF-8"
        run_as_root "(sed -i -e 's/# es_AR.UTF-8 UTF-8/es_AR.UTF-8 UTF-8/' /etc/locale.gen) && (dpkg-reconfigure --frontend=noninteractive locales) && update-locale LANG=es_AR.UTF-8"
        echo
        echo "Los cambios necesarios han sido aplicados."
        echo "Reinicie el sistema y luego vuelva a ejecutar esta instalación."
        exit 1
    fi
}

download_netkit () {
    # fetch basic netkit-ng packages
    echo "» Descargando netkit-ng desde el repositorio alternativo ..."
    test -d $NETKIT_DIR/bundles || mkdir $NETKIT_DIR/bundles
    ls ../netkit-*.tar.bz2 &> /dev/null && mv ../netkit-*.tar.bz2 $NETKIT_DIR/bundles
    if ! wget -q $SHOW_PROGRESS -P bundles -c $NETKIT_REPO/$NETKIT_CORE; then
        echo "ERROR: No es posible descargar los archivos. Verifique la conectividad y el proxy definido."
        echo
        exit 1
    fi
    wget -q $SHOW_PROGRESS -P bundles -c $NETKIT_REPO/$NETKIT_FS
    wget -q $SHOW_PROGRESS -P bundles -c $NETKIT_REPO/$NETKIT_KERNEL
    wget -q -P bundles -N $NETKIT_REPO/SHA256SUMS
}

download_labs () {
    test -d $NETKIT_DIR/labs || mkdir $NETKIT_DIR/labs
    # fetch labs built for the course (stored on GITHUB)
    for LAB in $LABS_GITHUB; do
        if ! wget -q -c $LABS_GITHUB_REPO/master/tarballs/$LAB.tar.gz?raw=true -O $NETKIT_DIR/labs/$LAB.tar.gz; then
            echo "ERROR: No es posible descargar los archivos. Verifique la conectividad y el proxy definido."
            echo
            exit 1
        fi
    done
    # fetch labs built for the course (stored on UNLU website)
    for LAB in $LABS_UNLU; do
        wget -q -P labs -c $NETKIT_REPO/$LAB.tar.gz
    done
    # fetch labs from the netkit basic-topics package
    for LAB in $LABS_BASIC; do
        wget -q -P labs -c $NETKIT_LABS/netkit-labs_basic-topics/$LAB/$LAB.tar.gz
    done
    # fetch labs from the netkit application-level package
    for LAB in $LABS_APPL; do
        wget -q -P labs -c $NETKIT_LABS/netkit-labs_application-level/$LAB/$LAB.tar.gz
    done
}

verify_netkit_integrity () {
    echo
    echo -n "» Verificando la integridad de los paquetes ... "
    cd $NETKIT_DIR/bundles
    if LANG=C sha256sum -c SHA256SUMS 2> /dev/null | grep "FAILED$"; then
        echo "ERROR: Alguno de los paquetes esta corrupto. Por favor descarguelo(s) nuevamente."
        echo
        exit 1
    else
        echo "OK"
    fi
    cd $NETKIT_DIR/
}

verify_updated_repositories () {
    # make sure repository indexes are no more than a month old
    if [[ -z "$(find /var/lib/apt/lists -mtime -30 -print -quit)" ]]; then
        echo
        echo "» Actualizando la lista de paquetes ..."
        run_as_root apt-get update
        echo
    fi
}

verify_required_packages () {
    if ! dpkg -s $REQUIRED_PACKAGES &> /dev/null; then
        echo
        echo "» Instalando paquetes requeridos ..."
        run_as_root apt-get install $REQUIRED_PACKAGES
        echo
    fi
}

validate_32bits_execution () {
    if [ $(uname -m) == 'x86_64' ]; then
        # if OS is 64 bits, install required packages to execute 32 bits binaries
        if ! dpkg -s libc6-i386 &> /dev/null; then
            echo
            echo "» Instalando libreria para ejecucion de binarios de 32 bits ..."
            run_as_root apt-get install libc6-i386
            echo
        fi
    fi
}

uncompress_everything () {
    echo "» Descomprimiendo el core de netkit, el sistema de archivos y el kernel ..."
    grep -qsF "version 3.0.4" $NETKIT_DIR/netkit-ng/netkit-version || \
        tar xSf bundles/$NETKIT_CORE --checkpoint=.2000
    grep -qsF "filesystem version F7.0" $NETKIT_DIR/netkit-ng/fs/netkit-filesystem-version || \
        tar xSf bundles/$NETKIT_FS --checkpoint=.2000
    grep -qsF "kernel version 3.2" $NETKIT_DIR/netkit-ng/kernel/netkit-kernel-version || \
        tar xSf bundles/$NETKIT_KERNEL --checkpoint=.2000
    echo
    echo "» Descomprimiendo los laboratorios ..."
    for LAB in $LABS_GITHUB $LABS_UNLU $LABS_BASIC $LABS_APPL; do
        tar xSf labs/$LAB.tar.gz
    done
    echo
}

fix_netkit_terminal () {
    # netkit and gnome-terminal do not get along well, so
    # we'll stay away from gnome-terminal at the moment
    sed -i 's/TERM_TYPE=gnome/TERM_TYPE=xterm/' $NETKIT_DIR/netkit-ng/netkit.conf
    # set larger xterm font (look up fixed fonts with xlsfonts)
    # prefer anti-aliased monospaced font and darker color
    sed -i 's/KERNELCMD="xterm -e /KERNELCMD="xterm -fa Monospace -fs 10 -fg gray -e /' $NETKIT_DIR/netkit-ng/bin/vstart
}

define_environment_vars () {
    # add relevant lines to bashrc
    grep -qF NETKIT_HOME ~/.bashrc || echo "export NETKIT_HOME=$NETKIT_DIR/netkit-ng" >> ~/.bashrc
    grep -qF MANPATH ~/.bashrc || echo "export MANPATH=:\$NETKIT_HOME/man" >> ~/.bashrc
    grep -qF NETKIT_HOME/bin ~/.bashrc || echo "export PATH=\$PATH:\$NETKIT_HOME/bin" >> ~/.bashrc
    # grep -qF netkit_bash_completion ~/.bashrc || echo "source \$NETKIT_HOME/bin/netkit_bash_completion" >> ~/.bashrc

    # TODO: reload .bashrc to apply recently defined values
    # source ~/.bashrc

    export NETKIT_HOME=$NETKIT_DIR/netkit-ng
    export MANPATH=:$NETKIT_HOME/man
    export PATH=$PATH:$NETKIT_HOME/bin
    # source $NETKIT_HOME/bin/netkit_bash_completion
}

show_outro () {
    echo
    echo "» Instalación finalizada."
    echo "  Pruebe iniciar un laboratorio con"
    echo
    echo "    cd"
    echo "    cd $NETKIT_DIR/netkit-lab_webserver"
    echo "    lstart"
    echo
}

# main

show_intro

if [[ $EUID -eq 0 ]]; then
    echo "ERROR: Este script debe ejecutarse como usuario común."
    echo
    exit 1
fi

# create main netkit directory
test -d $NETKIT_DIR || mkdir $NETKIT_DIR
cd $NETKIT_DIR/

if [[ "$LANG" =~ ^es_AR ]]; then
    verify_locale_utf8
fi
download_netkit
download_labs
verify_netkit_integrity
verify_updated_repositories
verify_required_packages
validate_32bits_execution
uncompress_everything
fix_netkit_terminal
define_environment_vars

cd $NETKIT_DIR/netkit-ng
./check_configuration.sh --fix

show_outro
exec "$BASH"
