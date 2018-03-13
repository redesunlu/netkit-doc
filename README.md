# Prácticas de Redes

Este repositorio contiene scripts, documentación y tips para utilizar [Netkit](http://wiki.netkit.org/index.php/Main_Page) en prácticas de Laboratorio de la asignatura de [Teleinformática y Redes](http://www.labredes.unlu.edu.ar/tyr), Universidad Nacional de Luján, Argentina.

# Contenido

Este repositorio cuenta con el siguiente contenido:

 * [Instalación y reinstalación](#descargar-el-instalador)
 * [Manual de uso de Netkit](manual-de-uso.md)
 * [FAQ](preguntas-frecuentes.md)
 * Script de instalación automática de Netkit en un entorno Debian o derivado.
 * Desinstalación

# Cómo usar este repositorio

El principal uso de este repo está en el script que automatiza la instalación de Netkit en un SO Debian.

## Descargar el instalador

Usando git:

```
git clone https://github.com/redesunlu/netkit-doc.git
cd netkit-doc/
```

O descargando el script en cuestión

```
wget https://raw.githubusercontent.com/redesunlu/netkit-doc/master/instalar-netkit-ng.sh
```

## Ejecutar el instalador

El script realiza todas las acciones necesarias para instalar Netkit de forma completa. Incluso agregar paquetes que no estén instalados. Puede tardar bastante en descargar, requiere al menos 2 GB de espacio, y solicita ejecutar algunas acciones como superusuario.

```
bash instalar-netkit-ng.sh
```

Leer toda la salida del comando que va mostrando información de estado, y los pasos que va ejecutando. Al final el instalador muestra una forma de testear la instalación.

## Reinstalar

Si fuera necesario comenzar la instalación de nuevo, el script puede ejecutarse sin tener que descargar nuevamente los archivos más "pesados".

Sólo hace falta eliminar todas los directorios de '~/netkit/' salvo el llamado 'bundles'.

```
rm -rf ~/netkit/labs ~/netkit/netkit*
```

# Desinstalar

Para desinstalar solo es necesario eliminar la carpeta `~/netkit` y eliminar las lineas de `~/.bashrc` similares a las siguientes:

```
export NETKIT_HOME=/home/<user>/netkit/netkit-ng
export MANPATH=:$NETKIT_HOME/man
export PATH=$PATH:$NETKIT_HOME/bin
```
