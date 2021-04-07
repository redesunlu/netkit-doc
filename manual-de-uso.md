# Manual de uso de Netkit

Este manual tiene por objetivo ser una guía para el uso de Netkit.

This document is also available in [English](user-guide.en.md).

# ¿Qué es Netkit?

Netkit es una herramienta. Netkit permite crear maquinas virtuales. Estas VMs emulan un entorno de red sobre el cual se pueden realizar experimentos. Es posible capturar PDUs de diferentes protocolos de comunicación para analizarlos posteriormente.

# ¿Cómo se instala?

La asignatura ofrece un [script](https://github.com/redesunlu/netkit-doc) que realiza todos los pasos de instalación. Para el uso en esta asignatura, **recomendamos** el uso del mismo.

# Ya instalé netkit con el script ¿Ahora que hago?

Si seguiste los pasos de instalación, al final de la misma tenes que encontrar una salida como la siguiente:

```
» Instalación finalizada.
  Pruebe iniciar un laboratorio con
    cd
    cd /home/<username>/netkit/netkit-lab_webserver
    lstart
```

Hacé la prueba tal como te indica la salida. Eso debería iniciar 2 consolas como se ven en la siguiente imagen:

![Test de instalación de Netkit](img/test-instalacion.png)

Las consolas tienen nombres, que los usaremos en las explicaciones. En nuestro caso, una consola se llama ***client*** y la otra ***server***.

## El test funcionó perfecto, pero no entiendo que hice

Levantaste un laboratorio de Netkit. De momento, en la consola "original" (Donde copiaste y pegaste `lstart`), ahora copia, pega y ejecuta `lhalt`. Tienen que cerrarse las 2 consolas (tanto ***client*** como ***server***).

Mas adelante estudiaremos los laboratorios, seguí adelante con este manual.

## A mi no me funcionó el test

Varias cosas pueden haber fallado. Lo mas probable es que no hayas visto las consolas levantadas y el comando `lstart` mostró un error extraño. También puede ser que viste las consolas pero se cerraron muy rápido.

2 caminos a tomar:

 * Si sos valiente y querés aprender un poco más, revisá las [Preguntas Frecuentes](preguntas-frecuentes.md) pues allí registramos algunos problemas que suelen suceder, con sus posibles soluciones.
 * Si la línea de comandos no es lo tuyo, hacé lo siguiente: ejecutá el comando `lstart -v`. La salida de ese comando pegala en un archivo de texto y llamá a alguno de los docentes. Si no estas en la clase, adjuntá el archivo a un correo contándonos todo el detalle que te parezca relevante.

# Entonces ya esta instalado Netkit. ¿Cómo se usa?

La instalación de netkit agrega 2 grupos de comandos:

 * comandos con prefijo ***v***, que sirven para administrar VMs simples.
 * comandos con prefijo ***l***, que sirven para administrar Laboratorios.

# ¿Qué es un laboratorio?

Un laboratorio involucra normalmente varias VMs, y los comandos permiten gestionar grupos de VMs de forma cómoda.

Un laboratorio conecta todas las VMs con alguna topología lógica en función del objetivo del mismo.

# ¿Qué comandos de tipo ***v*** hay? ¿Para qué se usan?

 * `vstart mivm`: Inicia una VM de nombre **mivm**.
 * `vlist`: Lista las VMs que se están ejecutando actualmente.
 * `vhalt mivm`: Apaga la VM **mivm**.

# ¿Qué laboratorios de Netkit están instalados?

Cuando se instaló Netkit, se instalaron diversos laboratorios:

```
$ ls -l ~/netkit/
total 36
drwxrwxr-x  2 tomas tomas 4096 mar 21 18:29 bundles
drwxrwxr-x  2 tomas tomas 4096 mar 21 18:17 labs
drwxr-xr-x  8 tomas tomas 4096 ago 22  2016 netkit-lab_arp
drwxr-xr-x 10 tomas tomas 4096 ago 22  2016 netkit-lab_dns
drwxr-xr-x  7 tomas tomas 4096 ago 22  2016 netkit-lab_nat
drwxr-xr-x  5 tomas tomas 4096 ago 22  2016 netkit-lab_quagga
drwxr-xr-x  8 tomas tomas 4096 ago 22  2016 netkit-lab_rip
drwxr-xr-x  4 tomas tomas 4096 mar 22 16:19 netkit-lab_webserver
drwxr-xr-x  7 tomas tomas 4096 mar 22 16:19 netkit-ng
```

Todas los directorios que empiezan con `netkit-lab_` son laboratorios listos para ser utilizados. Cuando terminó la instalación, el instalador sugirió el uso de un laboratorio, y con un comando se iniciaron 2 VMs de forma automática.

Un laboratorio puede iniciar muchas VMs, siendo limitado por los recursos de Hardware del equipo que ejecuta Netkit.

# ¿Cómo se inicia un laboratorio de Netkit?

Cuando en un TP o en clase se indique que se inicie un laboratorio, los pasos a seguir son los siguientes:

 * Dirigirse al directorio particular. Por ejemplo, para el laboratorio de ***ARP***, dirigirse a `~/netkit/netkit-lab_arp`

 `$ cd ~/netkit/netkit-lab_arp`

 * Iniciar el laboratorio con el comando `lstart`.

 `$ lstart`

 * Ver las VMs iniciadas

 `$ vlist`

 * Finalizar el laboratorio

 `$ lhalt`

# ¿Cómo realizar una captura de un laboratorio?

Existen diversas maneras de hacer esto:

 * Las VMs cuentan con `tcpdump` y `tshark` instalado, entonces siempre se puede capturar desde alguna de las mismas.
 * Netkit ofrece una forma de capturar el tráfico de un laboratorio en ejecución. Pero para entender esto necesitamos primero ver algunos detalles mas.

## Salida del comando vlist

Correr el laboratorio de arp y ejecutar `vlist`:

```
$ cd ~/netkit/netkit-lab_arp
$ lstart
$ vlist
```

La salida se verá como la siguiente:

```
$ vlist
USER             VHOST               PID       SIZE  INTERFACES
tomas            pc1               16039      40620  eth0 @ A
tomas            pc2               17936      40620  eth0 @ C
tomas            pc3               19626      40620  eth0 @ C
tomas            r1                21467      40620  eth0 @ A, eth1 @ B
tomas            r2                23155      40620  eth0 @ C, eth1 @ B

Total virtual machines:       5    (you),        5    (all users).
Total consumed memory:   203100 KB (you),   203100 KB (all users).
```

En esta salida nos interesa la ultima columna (**INTERFACES**).

Se ven placas y redes a las que estas placas estan conectadas. Por ejemplo:

_eth0 @ A_ dice que la placa _eth0_ esta conectada a la red _A_.

A, B y C son las redes disponibles.

## Ya entendí, hay 3 redes y 5 dispositivos ¿Cómo capturo el trafico de alguna de las redes?

Se captura con el comando `vdump` y se redirige la salida a un archivo. Con el ejemplo anterior:

```
$ vdump C > captura.pcap
Running ==> uml_dump C

```

Se captura todo el tráfico que hay por la red C (pc2, pc3 y r2), y se almacena en el archivo captura.pcap.

## ¿Cómo se detiene la captura?

Cuando ya no necesites capturar mas, simplemente en la consola de ejecución de la captura presiona `Ctrl+C`.

## ¿Cómo puedo analizar la captura realizada?

La captura se generó con formato _pcap_. Se puede visualizar sin problemas con herramientas como `tshark` o `wireshark`.

## ¿Cómo se cierra el laboratorio?

En nuestra experiencia, cerrar las consolas una a una puede ser problemático. Aconsejamos utilizar el comando `lhalt` en la misma consola donde se lanzó el `lstart`.

Tener cuidado de estar en el directorio del laboratorio.

# TL;DR

Si ya leíste todo lo anterior, entonces acá dejamos una referencia rápida a todos los comandos explicados:

Para manejo de VMs:

```
$ vstart nombre-vm # inicia un vm de nombre nombre-vm
$ vlist # informacion util de las vm en ejecución
$ vhalt nombre-vm # apaga la vm nombre-vm
```

Para manejo de labos:

```
# Ir a la carpeta de un Laboratorio
# Si instalaste con nuestro instalador, estan en ~/netkit/netkit-lab_<tema>
#   donde <tema> puede ser: dns, arp, webserver,....
$ lstart # inicia todas las vms de un labo
$ lhalt # cierra todas las vms
```

Para capturar:

```
# Tienen que haber un labo corriendo
$ vdump <nombre-red> > archivo_de_captura.pcap
# Averiguar nombres de red con comando vlist
```
