Platform Support
================

Vagrant-DNS was originally developed for macOS (or Mac OS X back in the time). This had 2 main reasons:

1) All main developers are on macOS and have no good idea how to properly implement such a system for other OSes. Also, macOS makes it incredibly easy to do what vagrant-dns does.

2) We spoke to multiple Linux and Windows-Developers and found that a half-baked implementation of people not invested at the respective platform as a _convenient development_ platform is only harmful and might at worst mess with users systems in unintended ways. None of them have supplied us with a proper way to implement this.

Vagrant-DNS just recently gained support for Linux, more specificity systemd with resolved.

That said, we will happily accept any patches and want to encourage platform support beyond macOS, including ensuring further development of those solutions. Some of the groundwork for this has been layed. It might not be 100% finished, but we happily apply any changes necessary.

This document aims to be a guide to implementing support for other platforms.

How Vagrant-DNS currently works
===============================

In a nutshell, Vagrant-DNS starts a DNS server on a non-privileged port (5300 by default) and makes sure that the host operating system knows this server. If possible, it only does so for a specific, free, TLD (.test). As a fallback, it also supports pass-through, if you really want to play with ICANN domains.

The DNS server runs on all platforms.

Design Goals
============

Vagrant-DNS should not require superuser access for anything except reconfiguring the hosts DNS system. This is why there is a seperate "install" step that registers the Vagrant-DNS server to your system (for the configured TLDs). (Re)starts of the server (happening at startup of the machine) need to happen without superuser access.

macOS
=====

As a reference, here is how this works on macOS:

* `install` places a symlink in `/etc/resolver/{tld}` that links to a corresponding file in `.vagrant.d` with content similar to this one:

```
nameserver 127.0.0.1
port 5300
```

From then on, OS X will resolve all requests to that top level domain using the given resolver.

Linux
=====

With `systemd-resolved`, we finally got a mechanism that resembles the macOS approach, with some subtile differences.

* `install` creates a single file `vagrant-dns.conf`, even when multiple top level domains are configured:

```
[Resolve]
DNS=127.0.0.1:5300
Domains=~test ~othertld
```

This file is then copied into `/etc/systemd/resolved.conf.d/`. The macOS strategy of adding symlinks from config files to a file within `/home/<user>/` doesn't work since the user that runs systemd-resolved doesn't have permission to read there.

This makes zombie configurations likely. For example when `vagrant-dns` is not correctly uninstalled using its `uninstall` command, its `resolved` configuration will point to a non-existing server, potentially causing troubles.

(Open)BSD
=========

Here, the question is simple: Is editing resolv.conf an option? Any takers?

Windows
=======

Quite frankly, I have not enough understanding on how to implement this properly on Windows.

General Notes
=============

mDNS is not an option. It doesn't support subdomains and most implementations do not support multiple servers per machine. Thats sad, as all platforms come with good solutions for it.
