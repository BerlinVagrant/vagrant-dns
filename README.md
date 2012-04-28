# vagrant-dns

`vagrant-dns` allows you to configure a dns-server managing a development subdomain. It works much like pow, but manages Vagrant machines.

## Installation

If you use the gem version of Vagrant, use:

    $ gem install vagrant-dns

otherwise, use:

    $ vagrant gem install vagrant-dns

## Usage

In addition to your networking config, configure a toplevel domain and a `host_name` for your machine. Optionally configure a logger and the listen options for the DNS server, this setting is global:

```ruby
Vagrant::Config.run do |config|
  #...
  
  config.dns.tld = "dev"
  
  config.vm.host_name = "machine"
  config.vm.network :hostonly, "33.33.33.60"
end

# optional
VagrantDNS::Config.logger = Logger.new("dns.log")
VagrantDNS::Config.listen = [[:udp, "0.0.0.0", 5300]]
```

Then, register the DNS server as a resolver:

```bash
$ sudo vagrant dns --install
```

On OS X, this will create a file `/etc/resolver/dev`, which tells OS X to resolve the TLD `.dev` by using the resolver given in this file.

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

# Issues

* No autostart
* Currently, you need one TLD per environment
* Only A and AAAA records at the moment
* Only one record per machine ("hostname.tld")
* Advanced customization of record rules is not supported at the moment
* OS X only
* Alpha code
* `curl` takes unacceptably long to resolve