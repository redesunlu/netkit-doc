# Networking exercises

This repository contains scripts, documentation and tips for using [Netkit](http://wiki.netkit.org/index.php/Main_Page) in laboratory practices of the [Teleinformática y Redes](http://www.labredes.unlu.edu.ar/tyr) course at Universidad Nacional de Luján, Argentina

Este documento también está disponible en [Español](README.md).

# Content

This repository has the following content:

* [Installation and reinstallation](#download-the-installer)
* [Netkit user manual](user-guide.en.md)
* [FAQ](faq.en.md)
* Netkit automatic installer for Debian or derivative environment.
* Uninstallation

# How to use this repository

The main purpose of this repository is to allow the automatic installation of Netkit in a Debian OS.

## Download the installer

Using git:

    git clone https://github.com/redesunlu/netkit-doc.git cd netkit-doc/

Or downloading the relevant script

    wget https://raw.githubusercontent.com/redesunlu/netkit-doc/master/instalar-netkit-ng.sh

## Run the installer

The script performs all the required actions to fully install Netkit. It even adds packages that aren't installed by default. It requires at least 2 GB of free space, it may take a long time to download, and some steps may require the root or superuser password in order to complete.

    bash instalar-netkit-ng.sh

Please pay attention to the output of the installer script as it shows status information and the steps currently executing. After the process is done, you will be given a way to test the installation.

## Reinstall

If it were necessary to re-do the installation, the script can be executed without having to download the "heavy" files again.

Just remove all directories inside `~/netkit/`'` except for the so-called `bundles`.

    rm -rf ~/netkit/labs ~/netkit/netkit*

## Uninstall

Just remove the `~/netkit` folder and remove the `~/.bashrc` lines which are similar to the following:

```
export NETKIT_HOME=/home/<user>/netkit/netkit-ng
export MANPATH=:$NETKIT_HOME/man
export PATH=$PATH:$NETKIT_HOME/bin
```
