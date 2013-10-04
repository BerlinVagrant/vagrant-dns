# vagrant-dns

`vagrant-dns` allows you to configure a dns-server managing a development subdomain. It works much like pow, but manages Vagrant machines.

## Installation

    $ vagrant plugin install vagrant-dns

## Usage

In addition to your networking config, configure a toplevel domain and a `hostname` for your machine. Optionally, configure a set of free matching patterns. Global configuration options can be given through the `VagrantDNS::Config` object:

```ruby
Vagrant.configure("2") do |config|
  #...

  config.dns.tld = "dev"

  config.vm.hostname = "machine"

  config.dns.patterns = [/^.*mysite.dev$/, /^.*myothersite.dev$/]

  config.vm.network :private_network, ip: "33.33.33.60"
end

# optional
VagrantDNS::Config.logger = Logger.new("dns.log")
```

Then, register the DNS server as a resolver:

```bash
$ vagrant dns --install
```

On OS X, this will create a file `/etc/resolver/dev`, which tells OS X to resolve the TLD `.dev` by using the nameserver given in this file. You will have to rerun --install every time a tld is added.

You can delete this file by running:

```bash
$ vagrant dns --uninstall
```

To also delete the created config file for this TLD (`~/.vagrant.d/tmp/dns/resolver/dev` in our example) run:


```bash
$ vagrant dns --purge
```

Then, run the DNS server:

```bash
$ vagrant dns --start
```

And test it:

```bash
$ scutil --dns
...
resolver #8
  domain   : dev
  nameserver[0] : 127.0.0.1
  port     : 5300
...
$ dscacheutil -q host -a name test.machine.dev
name: test.machine.dev
ip_address: 33.33.33.10
```

You can now reach the server under the given domain.

**Note:** Mac OS X is quite different from Linux regarding DNS resolution. As a result, do not use
`dig` or `nslookup`, but `dscacheutil` instead. Read [this article](http://apple.stackexchange.com/a/70583)
for more information.

**Note:** Chrome users could still encounter problems resolving hosts in the development subdomain(s).
If this is the case, make sure to turn of the [Built-in Asynchronous DNS](https://plus.google.com/100132233764003563318/posts/JXcvYw1yCkH)
client. The built-in DNS client not handling split DNS is [reported](https://code.google.com/p/chromium/issues/detail?id=265970).

Finally, stop the server using:

```bash
$ vagrant dns --stop
```

The DNS server will start automatically once the first VM is started.

## VM options

* `vm.dns.tld`: Set the tld for the given virtual machine. No default.
* `vm.dns.tlds`: Set multiple tlds. Default: `[tld]`
* `vm.dns.patterns`: A list of domain patterns to match. Defaults to `[/^.*{host_name}.{tld}$/]`

## Global Options

* `VagrantDNS::Config.listen`: an Array of Arrays describing interfaces to bind to. Defaults to `[[:udp, "127.0.0.1", 5300]]`.
* `VagrantDNS::Config.auto_run`: (re)start and reconfigure the server every time a machine is started. On by default.

## Issues

* A records only
* no ipv6 support
* OS X only (please read: [Platform
  Support](https://github.com/BerlinVagrant/vagrant-dns/blob/master/PLATFORM_SUPPORT.md) before ranting about this).
* Not visible inside the box
