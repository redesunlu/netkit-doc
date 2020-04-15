# Preguntas (no tan frecuentes) de Netkit-NG

This document is also available in [English](faq.en.md).

### Al iniciar una máquina virtual, la misma no tiene conectividad. De hecho, ni siquiera tiene interfaz eth0. ¿Qué puede estar sucediendo?

En algunos casos Netkit tiene una interacción incorrecta contra la terminal
Gnome-Terminal, por lo cual las máquinas virtuales inician sin interfaces de
red. Puede verificar si posee este problema ejecutando el comando
`ip link` tal como se muestra en este ejemplo:

    $ ip link show eth0
    Device "eth0" does not exist.

Si la salida del comando es la aquí indicada, se trata de este bug.

Este inconveniente se resuelve fácilmente, definiendo que se utilice la
terminal Xterm en vez de Gnome-Terminal.

Para ello, edite el archivo `~/netkit/netkit-ng/netkit.conf` y reemplace la 
línea `TERM_TYPE=gnome` (aprox. linea 40) por `TERM_TYPE=xterm`. Luego detenga
y vuelva a iniciar el laboratorio o las máquinas virtuales que requiera.


### Al iniciar una máquina virtual, aparecen varios errores similares al siguiente y no es posible escribir comandos en la terminal. ¿Qué puede estar sucediendo?

     mtime mismatch (1314283784 vs 1314285563) of COW header vs backing file

Este error aparece cuando el filesystem que es común a todas las máquinas
virtuales fue cambiado o actualizado, mientras que el disco virtual generado
para la máquina hace referencia a un filesystem anterior.

Este inconveniente se resuelve eliminando los discos virtuales con el comando
`lclean`, dentro del laboratorio en el que surgen los errores. Recuerde que
`lclean` elimina todos los cambios que pudieron haberse realizado en forma
manual sobre el sistema operativo de la máquina virtual.


### Al iniciar un laboratorio, sólo se inicia una máquina virtual, en la que aparece el mensaje siguiente durante varios minutos. ¿A qué se debe?

    INIT: version 2.88 booting
    [info] Using makefile-style concurrent boot in runlevel S.

Si se cumplen **todas** las siguientes condiciones:

- El sistema operativo donde ejecuta Netkit-NG es un sistema virtualizado,
- Está utilizando el software VirtualBox para ello, y
- Su computadora posee un procesador **sin soporte** para instrucciones de
  virtualización por hardware.

Entonces encontrará que, debido a las dificultades de emulación de las
instrucciones utilizadas por Netkit, la performance del sistema Netkit-NG es
sumamente baja y lo hace prácticamente inutilizable. Para resolver esta
situación:

- Averigüe si su equipo soporta instrucciones de virtualización asistidas
  por hardware, y si éste es el caso caso, actívelas. Usualmente esto se
  realiza mediante una opción en el BIOS.
- Si su equipo **no soporta** instrucciones de virtualización asistidas por
  hardware, le recomendamos que instale una distribución GNU/Linux tal como
  Ubuntu o Debian en modo Dual-Boot y ejecute Netkit-NG en dicha instalación.
- Como alternativa, pruebe instalar el sistema operativo en otro motor de
  virtualización diferente a VirtualBox.

Para averiguar si su equipo soporta este tipo de instrucciones, siga los pasos
indicados en [este enlace](https://blogs.technet.microsoft.com/davidcervigon/2007/04/26/soporta-mi-procesador-la-virtualizacin-asistida-por-hardware/).

### Cerré la ventana de una máquina virtual y ahora no puedo volver a iniciar el laboratorio. ¿Cómo puedo resolverlo?

Habitualmente, dado que un laboratorio involucra múltiples ventanas,
terminamos cerrando alguna por error, sin detener adecuadamente el laboratorio.
En este caso, suele suceder que quede en ejecución el proceso que gestiona
la o las máquinas virtuales, y el proceso que simula el dispositivo de
interconexión (hub o switch).

Para resolver este problema, conviene ejecutar las siguientes instrucciones,
en el orden dado:

    lhalt
    pkill netkit-kernel
    sudo pkill uml_switch
    lclean

El comando `lhalt` intenta detener el laboratorio actual en forma "adecuada".
El comando `pkill netkit-kernel` intentará detener todos los procesos de
máquinas virtuales de netkit que pudieran haber quedado en ejecución. El
comando `pkill uml_switch` intentará detener el proceso que simula el
dispositivo de interconexión, para lo cual es necesario tener privilegios de
administración (mediante sudo o su). Finalmente, el comando `lclean` elimina
los discos de las máquinas virtuales que hubieran quedado generados.


### ¿Es posible indicar que siempre se ejecute cierto comando al inicio de una máquina virtual?

Sí. Dentro de cada laboratorio hay un archivo llamado igual que la máquina
virtual, con extensión `.startup`. Por ejemplo, en el laboratorio webserver
existen `client.startup` y `server.startup`, que contienen los comandos que
se ejecutan luego de iniciar las máquinas cliente y servidor, respectivamente.

Basta con agregar las líneas que se desean ejecutar al final del archivo
correspondiente a la máquina virtual que nos interesa para que los comandos
se ejecuten luego de iniciada la VM.

### ¿Es posible acceder desde una máquina virtual a los archivos del host? ¿Cómo?

Sí, es posible. Netkit automáticamente genera el directorio `/hosthome` dentro de la máquina virtual, apuntando al home 
del usuario que lanzó el proceso (con vstart o lstart).

En el caso de que se haya iniciado un laboratorio (con lstart), también está disponible dentro de 
la máquina virtual el directorio `/hostlab` para acceder al contenido del laboratorio en el host.

### ¿Puedo extraer archivos que están en la máquina virtual y copiarlos al host?

Sí. Los directorios `/hosthome` y `/hostlab` se comparten entre host y máquina
virtual, por lo que todo archivo que se coloque allí pasará a estar en el host.
Basta con ejecutar

    cp ARCHIVO /hostlab/

para que el archivo indicado esté disponible en el host, dentro del directorio
del laboratorio.

### ¿Puedo realizar una captura de tráfico dentro de una máquina virtual?

Si bien la recomendación es utilizar `vdump` para capturar el tráfico desde
el host, nada impide que uno pueda capturar tráfico dentro de una máquina
virtual. Para ello, utilice el comando `tshark` o `tcpdump` con los
parámetros adecuados. Por ejemplo:

    # para capturar todo el tráfico en un archivo
    tcpdump -i eth0 -w captura.pcap

    # para capturar todo el tráfico en un archivo y guardarlo directamente en el directorio del lab en el host
    tcpdump -i eth0 -w /hostlab/captura.pcap
    
    # para mostrar sólo el tráfico de dns y smtp en pantalla
    tcpdump -i eth0 -t -q port domain or port smtp

    # para guardar sólo el tráfico de dns directamente en el host, dentro del home del usuario
    tcpdump -i eth0 -t -q port domain -w /hosthome/captura_dns.cap

### Intenté realizar una captura con el comando `tshark` dentro de un host, pero encuentro alguno de los siguientes errores. ¿Qué puede estar sucediendo?

    ...
    Unhandled exception (group=1, code=7)
    Aborted

o bien

    Out of memory: Kill process 1604 (tshark) score 625 or sacrifice child
    Killed process 1604 (tshark) total-vm:68236kB, anon-rss:19536kB, file-rss:4kB
    Killed

A diferencia de `tcpdump`, el analizador `tshark` incorpora
[disectores](https://www.wireshark.org/docs/wsdg_html_chunked/ChapterDissection.html) para una gran variedad de protocolos de red, por lo que requiere disponer de una
buena cantidad de memoria RAM en la máquina virtual donde se realiza la captura.

Dado que habitualmente los laboratorios se proveen con la configuración por
defecto, la configuración de 32 MB asignados para cada máquina virtual es
insuficiente e impide a `tshark` iniciar correctamente.

Esto se resuelve incrementando la cantidad de memoria disponible para las VMs
en el archivo de configuración del laboratorio `lab.conf`, añadiendo (o
reemplazando, si ya existiese) una línea como la siguiente, donde _maquina_
es el nombre del host o VM a modificar:

    maquina[mem]=128

Por ejemplo, para asignar 128 MB al _cliente_ del laboratorio _webserver_, la
línea en el archivo `webserver/lab.conf` quedaría así:

    client[mem]=128

Empíricamente hemos observado que asignando 128 MB a cada máquina virtual (o al
menos a aquella donde se realiza la captura), `tshark` se inicia y puede operar
correctamente, pero [YMMV](http://quesignificado.com/ymmv/).

### ¿Es posible ejecutar una máquina virtual sin iniciar una nueva ventana de terminal?

Sí. Es posible redirigir la salida de la terminal a la consola actual,
agregando el argumento `--con0=this` al comando `vstart`. Tenga en cuenta
que los comandos que escriba en la ventana actual, a partir de ahora se
ejecutarán sobre la máquina virtual. Por ejemplo

    $ vstart --con0=this mi-maquina

Para detener la máquina virtual, ejecute el comando `poweroff` dentro de
la misma terminal. Asegúrese, por supuesto, de no ejecutarlo sobre el host!

### ¿Es posible configurar la aplicación de terminal para que no se ejecute xterm por defecto?

Si. Para esto, hay que editar el archivo netkit.conf que el script de instalación ubica 
por defecto en `~/netkit/netkit-ng/netkit.conf` y modificar la setting:

    TERM_TYPE=xterm

por

    TERM_TYPE=gnome

en el caso de querer utilizar la terminal del entorno Gnome o `konsole` en el caso de KDE.

A partir de ese momento, todos los lstart/vstart que ejecutemos van a correr con la terminal
global que se definió, con el detalle de que (al menos en Gnome) si ya tenemos una terminal
abierta (mismo para ejecutar el `lstart/vstart`) las máquinas virtuales se visualizarán en
pestañas nuevas de la terminal, no en una ventana nueva como con xterm. 

Igual, YMMV: este comportamiento se observó en Ubuntu 18.04.

---

* Mauro A. Meloni \<maurom at dominio de la unlu\>
* Tomas Delvechio \<tdelvechio at dominio de la unlu\>
* Marcelo Fernandez \<fernandezm at dominio de la unlu\>
