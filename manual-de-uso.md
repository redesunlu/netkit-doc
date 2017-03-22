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

