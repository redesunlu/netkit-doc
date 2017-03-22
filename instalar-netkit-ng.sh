#!/bin/bash

set -e

NETKIT_REPO=http://www.marcelofernandez.info/files
NETKIT_LABS=http://wiki.netkit.org/netkit-labs
NETKIT_CORE=netkit-ng-core-32-3.0.4-TYR.tar.bz2
NETKIT_FS=netkit-ng-filesystem-i386-F7.0-0.1.3-TYR.tar.bz2
NETKIT_KERNEL=netkit-ng-kernel-i386-K3.2-0.1.3-TYR.tar.bz2
NETKIT_DIR=~/netkit
LABS_BASIC="netkit-lab_arp netkit-lab_quagga netkit-lab_rip"
LABS_APPL="netkit-lab_webserver netkit-lab_dns netkit-lab_nat"
PAQUETES_REQUERIDOS="bzip2 lsof uml-utilities xterm gnome-terminal wireshark tshark tcpdump"

# validar que tengamos wget
test -x /usr/bin/wget || como_root apt-get install wget

# validar que wget tenga show-progress
SHOW_PROGRESS=""
if wget --help | grep -qF "show-progress"; then
    SHOW_PROGRESS="--show-progress"
fi


como_root () {
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
    echo "   La instalación requiere al menos 1 GB de espacio disponible."
    echo "   Todos los archivos se almacenarán en el directorio $NETKIT_DIR"
    echo
    echo "   Verifique la documentación disponible en"
    echo "      https://github.com/redesunlu/netkit-doc"
    echo "==================================================================="
    echo
}

validar_locale_utf8 () {
    # validar que la locale sea utf8, de no ser asi, gnome-terminal no levanta
    if [[ ! "$LANG" =~ UTF-8$ ]]; then
        # forzar el establecimiento de locale
        echo "ERROR: Su sistema debe utilizar un lenguaje con codificación UTF-8"
        como_root "(sed -i -e 's/# es_AR.UTF-8 UTF-8/es_AR.UTF-8 UTF-8/' /etc/locale.gen) && (dpkg-reconfigure --frontend=noninteractive locales) && update-locale LANG=es_AR.UTF-8"
        echo
        echo "Los cambios necesarios han sido aplicados."
        echo "Reinicie el sistema y luego vuelva a ejecutar esta instalación."
        exit 1
    fi
}

descargar_netkit () {
    # obtener los paquetes basicos
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
    wget -q -P bundles -c $NETKIT_REPO/SHA256SUMS
}

descargar_labs () {
    # obtener algunos laboratorios
    test -d $NETKIT_DIR/labs || mkdir $NETKIT_DIR/labs
    for LAB in $LABS_BASIC; do
    wget -q -P labs -c $NETKIT_LABS/netkit-labs_basic-topics/$LAB/$LAB.tar.gz
    done
    for LAB in $LABS_APPL; do
    wget -q -P labs -c $NETKIT_LABS/netkit-labs_application-level/$LAB/$LAB.tar.gz
    done
}

verificar_integridad_netkit () {
    echo
    echo -n "» Verificando la integridad de los paquetes ... "
    cd $NETKIT_DIR/bundles
    if sha256sum --quiet -c SHA256SUMS; then
        echo "OK"
    else
        echo "ERROR: Alguno de los paquetes esta corrupto. Por favor descarguelo(s) nuevamente."
        echo
        exit 1
    fi
    cd $NETKIT_DIR/
}

verificar_paquetes_requeridos () {
    if ! dpkg -s $PAQUETES_REQUERIDOS &> /dev/null; then
        echo
        echo "» Instalando paquetes requeridos ..."
        como_root apt-get install $PAQUETES_REQUERIDOS
        echo
    fi
}

validar_ejecucion_32bits () {
    if [ $(uname -m) == 'x86_64' ]; then
        # si el sistema operativo es de 64 bits, instalar lo requerido para ejecutar 32 bits
        if ! dpkg -s libc6-i386 &> /dev/null; then
            echo
            echo "» Instalando libreria para ejecucion de binarios de 32 bits ..."
            como_root apt-get install libc6-i386
            echo
        fi
    fi
}

descomprimir_todo () {
    echo "» Descomprimiendo el core de netkit, el sistema de archivos y el kernel ..."
    grep -qsF "version 3.0.4" $NETKIT_DIR/netkit-ng/netkit-version || \
        tar xSf bundles/$NETKIT_CORE --checkpoint=.2000
    grep -qsF "filesystem version F7.0" $NETKIT_DIR/netkit-ng/fs/netkit-filesystem-version || \
        tar xSf bundles/$NETKIT_FS --checkpoint=.2000
    grep -qsF "kernel version 3.2" $NETKIT_DIR/netkit-ng/kernel/netkit-kernel-version || \
        tar xSf bundles/$NETKIT_KERNEL --checkpoint=.2000
    echo
    echo "» Descomprimiendo los laboratorios ..."
    for LAB in $LABS_BASIC $LABS_APPL; do
        tar xSf labs/$LAB.tar.gz
    done
    echo
}

definir_variables_entorno () {
    # agregar las lineas relevantes a bashrc
    grep -qF NETKIT_HOME ~/.bashrc || echo "export NETKIT_HOME=$NETKIT_DIR/netkit-ng" >> ~/.bashrc
    grep -qF MANPATH ~/.bashrc || echo "export MANPATH=:\$NETKIT_HOME/man" >> ~/.bashrc
    grep -qF NETKIT_HOME/bin ~/.bashrc || echo "export PATH=\$PATH:\$NETKIT_HOME/bin" >> ~/.bashrc
    # grep -qF netkit_bash_completion ~/.bashrc || echo "source \$NETKIT_HOME/bin/netkit_bash_completion" >> ~/.bashrc

    # TODO: recargar .bashrc para tomar los valores definidos
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

# crear el directorio principal
test -d $NETKIT_DIR || mkdir $NETKIT_DIR
cd $NETKIT_DIR/

validar_locale_utf8
descargar_netkit
descargar_labs
verificar_integridad_netkit
verificar_paquetes_requeridos
validar_ejecucion_32bits
descomprimir_todo
definir_variables_entorno

cd $NETKIT_DIR/netkit-ng
./check_configuration.sh --fix

show_outro
exec "$BASH"
