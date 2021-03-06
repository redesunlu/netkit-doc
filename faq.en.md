# (Not so Frequently Asked) Questions about Netkit-NG

Este documento también está disponible en [Español](preguntas-frecuentes.md).

### Upon starting, the virtual machine seems to be disconnected from the network. In fact, it does not even have an eth0 interface. What may be happening?

We've experienced some problems using Netkit together with Gnome-Terminal, whereby the virtual machines start without any network interface. You can check if you have this problem by executing the `ip link` command as shown in this example:

    $ ip link show eth0
    Device "eth0" does not exist.

If the output of the command is the one indicated here, then you're being bitten by this bug.

This problem can be easily solved by instructing Netkit to use Xterm instead of Gnome-Terminal. To do so, open the `~/netkit/netkit-ng/netkit.conf` file with a text editor and replace the line `TERM_TYPE=gnome` (around line 40) with `TERM_TYPE=xterm`. Then stop and restart the lab and/or virtual machines affected.

### When starting a virtual machine, I see several errors like the following, and I am unable to write commands at the terminal. What may be happening?

     mtime mismatch (1314283784 vs 1314285563) of COW header vs backing file

This error shows up when the base filesystem shared between all the virtual machines has changed or has been updated, while the virtual disk generated for each machine refers to the previous filesystem.

This problem can be easily solved by deleting the virtual disks with the `lclean` command inside the laboratory in which the errors arise. But remember that `lclean` removes all the changes that could have been made manually on the operating system of the virtual machine.

### When starting a lab, only one virtual machine starts up, and then the following message appears for several minutes. Why is that?

    INIT: version 2.88 booting
    [info] Using makefile-style concurrent boot in runlevel S.

If **all these conditions** are fullfilled:

- The operating system where Netkit-NG runs is a virtualized system,
- You are using the VirtualBox software to do so, and
- Your computer has a **CPU without support** for hardware virtualization instructions (Intel VT-x, AMD-V).

Then you will then find that due to the complexity of emulation of the instructions used by Netkit, the performance of the Netkit-NG system is extremely low and it makes the system practically unusable.

To solve this:

- Find out if your computer supports hardware-assisted virtualization instructions, and if that is the case, activate them. Usually this can be done through a BIOS switch.
- If your computer **does not support** hardware-assisted virtualization instructions, we recommend installing a GNU/Linux distribution such as Ubuntu or Debian in Dual-Boot mode and running Netkit-NG in that environment.
- As an alternative, try installing the operating system on another virtualization engine apart from VirtualBox.

To find out if your computer supports hardware virtualization instructions, follow the steps indicated in [this link](https://blogs.msdn.microsoft.com/taylorb/2008/06/19/hyper-v-will-my-computer-run-hyper-v-detecting-intel-vt-and-amd-v/).

### When starting a lab, the following message is shown and nothing else happens. What may be happening?

    You choose to use parallel startup.
    /home/usuario/netkit/netkit-ng/bin/lstart: 371: /home/usua
    rio/netkit/bin/lstart: make: not found

    The lab has been started

There is a high chance that the current laboratory settings specify
a parallel startup of virtual machines. This startup method requires
that the "make" command is available on Linux, but "make" is not
currently listed as a Netkit dependency.

There are three ways to solve this:

- Install the make command by running `apt-get install make` as
  root user or using sudo.

- Specify the `-s` argument when running lstart, like `lstart -s` or  
  `lstart --sequential` so that the make command is made optional.

- Remove the `lab.dep` file that is listed on the laboratory directory
  so the VMs are sequentially started.

### I closed the window of a virtual machine and now I cannot restart the lab. How can I solve it?

As a laboratory involves multiple windows, we may end up closing one by mistake, without having properly stopped the whole lab. In this case, it usually happens that the process managing the virtual machine(s), and the process that simulates the interconnection device (hub or switch), both keep running wild.

To solve this, execute the following instructions in the given order, waiting a few seconds between each command:

    lhalt
    pkill netkit-kernel
    sudo pkill uml_switch
    lclean

The `lhalt` command first tries to stop the current lab in an "adequate" way. The `pkill netkit-kernel` command will try to stop all netkit virtual machine processes that may have been running. The command `pkill uml_switch` will try to stop the process that simulates the interconnection device, for which it is necessary to have administrative privileges (through sudo or su). Finally, the `lclean` command removes the disks of the virtual machines that have been generated.

### Is it possible to run commands automatically when starting a virtual machine?

Yes, it is. Inside each laboratory there is a file with the same name as the virtual machine, with a `.startup` extension. For example, in the webserver laboratory there are `client.startup` and `server.startup`, both of which contain the commands that are executed after starting the client and server machines, respectively.

Just add the lines that you want to execute at the end of the file whose name matches the virtual machine that you're interested in, and those commands will be executed after that VM has started. Remember to pay attention to the syntax of each command, as any error will render those commands inneffective.

### Is it possible to access the host files from a virtual machine? How?

Yes, it is. Netkit automatically generates a `/hosthome` directory inside the virtual machine, pointing to the home directory of the user who launched the process (with vstart or lstart).

In the event that a laboratory has been started (with lstart), the `/hostlab` directory is also available within the virtual machine, allowing to access the contents of the host's lab directory on the guest.

### Can I extract files that are in the virtual machine and copy them to the host?

Yes. The `/hosthome` and`/hostlab` directories are shared between host and virtual machine, so any file placed there will also be on the host. Just execute

    cp FILENAME /hostlab/

and that file will be available on the host, inside the current laboratory directory.

### Can I capture traffic inside a virtual machine?

While the recommendation is to use `vdump` to capture traffic between hosts, nothing prevents us from capturing traffic inside a virtual machine. To do so, use the `tshark` or `tcpdump` commands with the suitable parameters. For example:

    # to capture all the traffic and save it to a file
    tcpdump -i eth0 -w capture.pcap

    # to capture all traffic and save it directly to the lab directory on the host
    tcpdump -i eth0 -w /hostlab/capture.pcap

    # to only display dns and smtp traffic on screen
    tcpdump -i eth0 -t -q port domain or port smtp

    # to save only the dns traffic directly on the host, inside the user's home directory
    tcpdump -i eth0 -t -q port domain -w /hosthome/captura_dns.cap

### I tried to capture traffic with `tshark` inside a host, but it fails with one of the following errors. What may be happening?

    ...
    Unhandled exception (group=1, code=7)
    Aborted

or

    Out of memory: Kill process 1604 (tshark) score 625 or sacrifice child
    Killed process 1604 (tshark) total-vm:68236kB, anon-rss:19536kB, file-rss:4kB
    Killed

Unlike `tcpdump`, the `tshark` analyzer uses
[dissectors](https://www.wireshark.org/docs/wsdg_html_chunked/ChapterDissection.html)
to examine a wide variety of network protocols, so you need to have a good
amount of RAM on the virtual machine where the capture is being performed.

Since laboratories are usually provided with a minimal configuration,
the 32 MB of RAM assigned to each virtual machine are not enough for it and
prevent `tshark` from working correctly.

This can be solved by increasing the memory limit of the VMs in the lab
configuration file `lab.conf`, by adding (or replacing, if it already existed)
a line like the following, where _machine_ is the name of the host or VM to modify:

    machine[mem] = 128

For example, to set apart 128 MB for the _client_ in the _webserver_ lab, the
line in the `webserver/lab.conf` file would look like this:

    client[mem] = 128

We have empirically observed that allocating 128 MB for each virtual machine
(or at least for the one with the capture role), `tshark` starts and can
operate successfully, but YMMV.

### Is it possible to run a virtual machine without starting a new terminal window?

Yes, it is. You can redirect the output from the VM to the current terminal, adding the `--con0=this` argument to the `vstart` command. Keep in mind that, from now, any command you type in the current window will run on the virtual machine. For example

    $ vstart --con0=this my-machine

To stop the virtual machine, run the `poweroff` command inside the same terminal. Make sure not to run it on the host!

---

Content by

* Mauro A. Meloni \<maurom at unlu mail server\>
* Tomas Delvechio \<tdelvechio at unlu mail server\>
* Marcelo Fernandez \<fernandezm at unlu mail server\>
