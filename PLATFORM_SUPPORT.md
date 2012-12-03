Platform Support
================

Vagrant-DNS only supports OS X at the moment. This has 2 main reasons:

1) All main developers are on OS X and have no good idea how to properly implement such a system for other OSes. Also, OS X makes it incredibly easy to do what vagrant-dns does.

2) We spoke to multiple Linux and Windows-Developers and found that a half-baked implementation of people not invested at the respective platform as a _convenient development_ platform is only harmful and might at worst mess with users systems in unintended ways. None of them have supplied us with a proper way to implement this.

That said, we will happily accept any patches and want to encourage platform support beyond OS X, including ensuring further development of those solutions. Some of the groundwork for this has been layed. It might not be 100% finished, but we happily apply any changes necessary.

This document aims to be a guide to implementing support for other platforms.

How Vagrant-DNS currently works
===============================

In a nutshell, Vagrant-DNS starts a DNS server on a non-privileged port (5300 by default) and makes sure that the host operating system knows this server. If possible, it only does so for a specific, free, TLD (.dev). As a fallback, it also supports pass-through, if you really want to play with ICANN domains.

The DNS server runs on all platforms.

Design Goals
============

Vagrant-DNS should not require superuser access for anything except reconfiguring the hosts DNS system. This is why there is a seperate "install" step that registers the Vagrant-DNS server to your system (for the configured TLDs). (Re)starts of the server (happening at startup of the machine) need to happen without superuser access.

Mac OS X
========

As a reference, here is how this works on OS X:

* `install` places a symlink in `/etc/resolver/{tld}` that links to a corresponding file in `.vagrant.d` with content similar to this one:

```
nameserver 127.0.0.1
port 5300
```

From then on, OS X will resolve all requests to that top level domain using the given resolver.

Linux
=====

To help anyone that attempts a Linux implementation, here is what has already been tried.

* Editing resolv.conf: Linux resolv.conf (in contrast to, say OpenBSD) does not allow you to set a port number for the DNS server. Also, its size is limited to 3 servers and the file is often under OS control, so messing around with it might not be advisable.
* Setting up dnsmasq: this is certainly an option, but we couldn't find out how invasive this was, which Linux flavors might already come with dnsmasq configurations and how not to shoot other people in the foot with it. User help is needed.

(Open)BSD
=========

Here, the question is simple: Is editing resolv.conf an option? Any takers?

Windows
=======

Quite frankly, I have not enough understanding on how to implement this properly on Windows.

General Notes
=============

mDNS is not an option. It doesn't support subdomains and most implementations do not support multiple servers per machine. Thats sad, as all platforms come with good solutions for it.