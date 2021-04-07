# Netkit user guide

This document is intended as a guide to use Netkit.

Este documento también está disponible en [Español](manual-de-uso.md).

## But, what is Netkit?

Netkit is a tool. Netkit allows you to create virtual machines. These VMs emulate a network environment on which experiments can be performed. It is possible to capture PDUs of different communication protocols for later analysis.

## How can I install it?

This course offers a [script](https://github.com/redesunlu/netkit-doc) that performs all the installation steps. At the Teleinformática y Redes course, we **recommend** to use this installer.

## I have installed netkit using the script. What should I do now?

If you followed the installation steps, at the end of it you'll find a prompt like the following:

    » Instalación finalizada.
      Pruebe iniciar un laboratorio con
        cd
        cd /home/<username>/netkit/netkit-lab_webserver
        lstart

Run those commands to test the Netkit environment. Two terminal windows should start up. They'll look like the following image:

![Netkit installation test](img/test-instalacion.png)

Terminals have names, which we will refer later in the explanations. In this lab, one terminal is called ***client*** and the other ***server***.

## The test ran OK, but I didn't understand what I did

You set up a Netkit lab. Now, at the "original" terminal (where you copypasted `lstart`), copy, paste and run the `lhalt` command. The two terminals should close (both ***client*** and ***server***).

We will take a look at the laboratories later. For the time being, continue reading this guide.

## The test did not work in my machine

Several things may have failed. Most likely, you could not see the terminal windows starting up and the `lstart` command ended with a strange error. It could also be that you did saw the terminal windows but they shut down quickly.

There are 2 possible pathways:

* If you are brave and want to learn a little more, check [our FAQ](faq.en.md) as your problem may have been noted there and probably there is even a quick solution.
* If the command line is not your thing, do the following. Run the `lstart -v` command. Paste the output of that command into a text file and ask for one of the assistants. If you are not currently at the classroom, attach the file to an email telling us all the details that you think are relevant.

## So Netkit is now installed. How can I use it?

Netkit adds 2 groups of commands:

* commands prefixed with ***v***, which are used to manage simple VMs.
* commands prefixed with ***l***, which allow to manage laboratories.

## A lab? What is a laboratory?

A laboratory usually involves several VMs, and these commands allow to manage groups of VMs in a comfortable way.

A laboratory connects all VMs with some logical topology depending on the purpose of the lab.

## Which ***v*** commands are there? What are they used for?

* `vstart myvm`: Start a VM named ***myvm***.
* `vlist`: Lists the VMs that are currently running.
* `vhalt myvm`: Turn off the ***myvm*** VM.

## Which Netkit labs are installed?

When Netkit was installed, several laboratories were installed as well:

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

All directories prefixed with `netkit-lab_` are ready to be used labs. When the install process finished, the installer suggested the use of a lab, and after executing a command, two VMs were automatically started.

A laboratory can initiate many VMs, the only limit being the hardware resources of the equipment that executes Netkit.

## How can I start using a Netkit laboratory?

When a project or lecture requires the use of a laboratory, you should do the following:

* Go to the lab directory. For example, for the ***ARP*** lab, go to `~/netkit/netkit-lab_arp`

        $ cd ~/netkit/netkit-lab_arp

* Start the lab with the `lstart` command.

        $ lstart

* Take a look at the started VMs started

        $ vlist

* Close the laboratory

        $ lhalt

## How can I capture the network traffic in a laboratory?

There are several ways to do this:

* VMs have `tcpdump` and `tshark` installed, so you can always capture packets from any of them.
* Netkit offers a way to capture the traffic of a running laboratory by "sniffing" the network link. But to understand how to do it we need to know some details first.

### Output of the vlist command

Run the arp lab and run `vlist`:

    $ cd ~/netkit/netkit-lab_arp
    $ lstart
    $ vlist

The output will look like the following:

    $ vlist
    USER             VHOST               PID       SIZE  INTERFACES
    tomas            pc1               16039      40620  eth0 @ A
    tomas            pc2               17936      40620  eth0 @ C
    tomas            pc3               19626      40620  eth0 @ C
    tomas            r1                21467      40620  eth0 @ A, eth1 @ B
    tomas            r2                23155      40620  eth0 @ C, eth1 @ B

    Total virtual machines:       5    (you),        5    (all users).
    Total consumed memory:   203100 KB (you),   203100 KB (all users).

We are interested in the last column (**INTERFACES**).

You'll see interfaces (NICs) and networks to which these interfaces are connected. For example:

_eth0 @ A_ means that the _eth0_ interface is directly connected to the _A_ network/link.

A, B and C are the available networks.

### I get it: there are 3 networks and 5 devices. How do I capture the traffic in any of the networks?

You can type the `vdump` command and redirected the output to a file. Following the previous example:

    $ vdump C > capture.pcap
    Running ==> uml_dump C

You'll capture all traffic running on the C network (pc2, pc3 and r2), and store it in the `capture.pcap` file.

### How can I stop capturing packets?

When you no longer need to keep grabbing packets, simply press `Ctrl+C` on the window you're running the capture.

### How can I analyze the capture file?

The traffic dump is stored in a format called _pcap_. It can be easily analyzed with tools such as `tshark` or `wireshark`.

## How can I shut down a laboratory?

In our experience, closing terminals one by one can be problematic. We recommend to use the `lhalt` command at the same terminal where `lstart` was launched.

Be careful. You have to "be standing" at the right lab folder.

## TL;DR

If you already read all the above, here you have a quick reference of all the previous commands:

VMs management:

    $ vstart name-vm   # start a vm named name-vm
    $ vlist            # useful information of the running vms
    $ vhalt name-vm    # turn off the vm name-vm

Lab management:

    # Go to the laboratory folder
    # If you installed with our installer, they are in ~/netkit/netkit-lab_<subject>
    # where <subject> can be: dns, arp, webserver, ....
    $ lstart   # starts all vms on a lab
    $ lhalt    # closes all vms

Capturing packets:

    # There has to be a lab currently executing
    $ vdump <network-name> > capture_file.pcap
    # Find out network names with vlist command
