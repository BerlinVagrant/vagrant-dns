# vagrant-dns

`vagrant-dns` allows you to configure a dns-server managing a development subdomain. It works much like pow, but manages Vagrant machines.

## Installation

If you use the gem version of Vagrant, use:

    $ gem install vagrant-dns

otherwise, use:

    $ vagrant gem install vagrant-dns

## Usage

In addition to your networking config, configure a toplevel domain and a `host_name` for your machine. Global configuration options can be given through the `VagrantDNS::Config` object:

```ruby
Vagrant::Config.run do |config|
  #...
  
  config.dns.tld = "dev"
  
  config.vm.host_name = "machine"
  config.vm.network :hostonly, "33.33.33.60"
end

# optional
VagrantDNS::Config.logger = Logger.new("dns.log")
```

Then, register the DNS server as a resolver:

```bash
$ sudo vagrant dns --install
```

On OS X, this will create a file `/etc/resolver/dev`, which tells OS X to resolve the TLD `.dev` by using the nameserver given in this file.

You can delete this file by running:

```bash
$ sudo vagrant dns --uninstall
```

Then, run the DNS server:

```bash
$ vagrant dns --start
```

And test it:

```bash
$ dig @localhost -p 5300 test.machine.dev
```

You can now reach the server under the given domain.

Finally, stop the server using:

```bash
$ vagrant dns --stop
```

## VM options

* `vm.dns.tld`: Set the tld for the given virtual machine. No default.
* `vm.dns.patterns`: A list of domain patterns to match. Defaults to `[/^.*{host_name}.{tld}$/]`

## Global Options

* `VagrantDNS::Config.logger`: a logger object to be used by the DNS server. Defaults to `$stderr`
* `VagrantDNS::Config.listen`: an Array of Arrays describing interfaces to bind to. Defaults to `[[:udp, "127.0.0.1", 5300]]`.

## Issues

* No autostart
* Multiple TLDs per environment are supported, but no 2 environments can share a TLD
* A records only
* no ipv6 support
* Only one record per machine ("hostname.tld")
* Advanced customization of record rules is not supported at the moment
* OS X only
* Alpha code