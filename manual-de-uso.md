# Manual de uso de Netkit

Este manual tiene por objetivo ser una guía para el uso de Netkit.

# ¿Que es Netkit?

Netkit es una herramienta. Netkit permite crear maquinas virtuales. Estas VMs emulan un entorno de red sobre el cual se pueden realizar experimentos. Es posible capturar PDUs de diferentes protocolos de comunicación para analizarlos posteriormente.

# ¿Como se instala?

Si bien existe una [pagina oficial del proyecto](http://wiki.netkit.org/index.php/Download_Official), la asignatura ofrece un [script](https://github.com/redesunlu/netkit-doc) que realiza todos los pasos de instalación. Para el uso en esta asignatura, **recomendamos** el uso del mismo.

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

 * Si sós valiente y querés aprender un poco mas, revisa [esta página](http://wiki.netkit.org/index.php/FAQ) con problemas y soluciones de Netkit. En particular, las preguntas dentro de ***Troubleshooting*** pueden ayudar un poco.
 * Si la linea de comando no es lo tuyo, hace lo siguiente: ejecuta el siguiente comando `lstart -v`. La salida de ese comando pegala en un archivo de texto y llama a alguno de los docentes. Si no estas en la clase, adjunta el archivo a un correo contándonos todo el detalle que te parezca relevante.

# Entonces ya esta instalado Netkit. ¿Como se usa?

La instalación de netkit agrega 2 grupos de comandos:

 * comandos con prefijo ***v***
 * comandos con prefijo ***l***

Los comandos de prefijos ***v*** sirven para administrar VMs simples.

Los que utilizan prefijos ***l*** sirven para administrar Laboratorios.

# ¿Que es un laboratorio?

Un laboratorio involucra normalmente varias VMs, y los comandos permiten gestionar grupos de VMs de forma cómoda.

Un laboratorio conecta todas las VMs con alguna topología lógica en función del objetivo del mismo.

# ¿Que comandos de tipo ***v*** hay? ¿Para que se usan?

 * `vstart mivm`: Inicia una VM de nombre **mivm**.
 * `vlist`: Lista las VMs que se estan ejecutando actualmente.
 * `vhalt mivm`: Apaga la VM **mivm**.

# ¿Que laboratorios de Netkit estan instalados?

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

# ¿Como se inicia un laboratorio de Netkit?

Cuando en un TP o en clase se indique que se inicie un laboratorio, los pasos a seguir son los siguientes:

 * Dirigirse al directorio particular. Por ejemplo, para el laboratorio de ***ARP***, dirigirse a `~/netkit/netkit-lab_arp`

 `$ cd ~/netkit/netkit-lab_arp`

 * Iniciar el laboratorio con el comando `lstart`.

 `$ lstart`

 * Ver las VMs iniciadas

 `$ vlist`

 * Finalizar el laboratorio

 `$ lhalt`

# ¿Como realizar una captura cuando un?
