# vagrant-dns

`vagrant-dns` allows you to configure a dns-server managing a development subdomain. It works much like pow, but manages Vagrant machines.

## Installation

    $ vagrant plugin install vagrant-dns

**Attention: As of v2.0.0, vagrant-dns requires vagrant >= 1.9.6** (because it ships with a more modern version of ruby)  
If you get an error like `rubydns requires Ruby version >= 2.2.6.` while installing, you probably need to upgrade vagrant.  
Alternatively, you can install an older version of vagrant-dns like this: `vagrant plugin install --plugin-version="<2" vagrant-dns` 

## Usage

In addition to your networking config, configure a top-level domain and a `hostname` for your machine. Optionally, configure a set of free matching patterns. Global configuration options can be given through the `VagrantDNS::Config` object:

```ruby
Vagrant.configure("2") do |config|
  # ...

  config.dns.tld = "test"

  config.vm.hostname = "machine"

  config.dns.patterns = [/^(\w+\.)*mysite\.test$/, /^(\w+\.)*myothersite\.test$/]

  config.vm.network :private_network, ip: "33.33.33.60"
end

# optional
VagrantDNS::Config.logger = Logger.new("dns.log")
```

Then, register the DNS server as a resolver:

```bash
$ vagrant dns --install
```

This command will write out a configuration file that tells the operating system to resolve the `.test` TLD via the `vagrant-dns` DNS server. On OS X, this config file is located at `/etc/resolver/test` while on Linux it's at `/etc/systemd/resolved.conf.d/vagrant-dns.conf`.

You will have to rerun --install every time a tld is added.

You can delete this file by running:

```bash
$ vagrant dns --uninstall
```

To also delete the created config file for this TLD (`~/.vagrant.d/tmp/dns/resolver/test` or `~/.vagrant.d/tmp/dns/resolver/vagrant-dns.conf` in our example) run:


```bash
$ vagrant dns --purge
```

Then, run the DNS server:

```bash
$ vagrant dns --start
```

And test it:

**OS X:**

```bash
$ scutil --dns
[ … ]
resolver #8
  domain   : test
  nameserver[0] : 127.0.0.1
  port     : 5300
[ … ]

$ dscacheutil -q host -a name test.machine.test
name: test.machine.test
ip_address: 33.33.33.10
```

**Linux**:

```bash
$ resolvectl status
Global
       Protocols: LLMNR=resolve -mDNS -DNSOverTLS DNSSEC=no/unsupported
resolv.conf mode: stub
      DNS Domain: ~test
[ … ]

$ resolvectl query test.machine.test
test.machine.test: 33.33.33.10

-- Information acquired via protocol DNS in 10.1420s.
-- Data is authenticated: no; Data was acquired via local or encrypted transport: no
```

**Note:** Mac OS X is quite different from Linux regarding DNS resolution. As a result, do not use
`dig` or `nslookup`, but `dscacheutil` instead. Read [this article](http://apple.stackexchange.com/a/70583)
for more information.


You can now reach the server under the given domain.

```bash
$ vagrant dns --stop
```

The DNS server will start automatically once the first VM is started.

You can list the currently configured dns patterns using:

```bash
$ vagrant dns --list
```

(Keep in mind, that it's not guaranteed that the running server uses exactly this configuration - for example, when manually editing it.)  
The output looks somewhat like this:

```
/^.*mysite.test$/ => 33.33.33.60
/^.*myothersite.test$/ => 33.33.33.60
```

Where the first part of each line is a [regular expression](https://ruby-doc.org/core-2.3.0/Regexp.html) and the second part is the mapped IPv4. (` => ` is just a separator)

## Multi VM config

We can use [multivm](https://www.vagrantup.com/docs/multi-machine/) configuration and have dns names for host.

* Use below given vagrant config
    ```ruby
    BOX_IMAGE = "ubuntu/xenial64"
    WORKER_COUNT = 2
    Vagrant.configure("2") do |config|
      (1..WORKER_COUNT).each do |i|
        config.vm.define "worker#{i}" do |subconfig|
          subconfig.dns.tld = "test"
          subconfig.vm.hostname = "vagrant"
          subconfig.dns.patterns = "worker#{i}.mysite.test"
          subconfig.vm.box = BOX_IMAGE
          subconfig.vm.network "private_network", ip: "10.240.0.#{i+15}"
        end
      end
    end
    ```
*  `vagrant up`
*  Execute : `vagrant dns --install`
*  Test via: `ping worker2.mysite.box` or `worker1.mysite.box`

## VM options

* `vm.dns.tld`: Set the tld for the given virtual machine. No default.
* `vm.dns.tlds`: Set multiple TLDs. Default: `[tld]`
* `vm.dns.patterns`: A list of domain patterns to match. Defaults to `[/^.*{host_name}.{tld}$/]`
* `vm.dns.ip`: Optional, overwrite of the default static IP detection. Valid values are:
  - `Proc`: A Proc which return value will get used as IP. Eg: `proc { |vm, opts| }` (See DHCP section for full sample)
  - `Symbol`: Forces the use of the named static network: 
    + `:private_network`: Use static ip of a configured private network (`config.vm.network "private_network", ip: "192.168.50.4"`)
    + `:public_network`: Use static ip of a configured public network (`config.vm.network "public_network", ip: "192.168.0.17"`)
    + `:dynamic`, `:dhcp`: Force reading the guest IP using vagrants build-in `read_ip_address` capability.
  - Default:
      If there is no network with a statically defined IP, and no `ip` override is given, use the build-in `read_ip_address` capability.
      Else, check `:private_network`, if none found check `:public_network`

## Global Options

* `VagrantDNS::Config.listen`: an Array of Arrays describing interfaces to bind to. Defaults to `[[:udp, "127.0.0.1", 5300]]`.
* `VagrantDNS::Config.ttl`: The time-to-live in seconds for all resources. Defaults to `300` (5 minutes).
* `VagrantDNS::Config.auto_run`: (re)start and reconfigure the server every time a machine is started. On by default.
* `VagrantDNS::Config.check_public_suffix`: Check if you are going to configure a [Public Suffix](https://publicsuffix.org/) (like a Top Level Domain) in a VMs `tld(s)` config, which could mess up your local dev machines DNS config. Possible configuration values are:
  - `false`: Disables the feature.
  - `"warn"`: Check and print a warning. (Still creates a resolver config and potentially messes up your DNS) **At the moment, this is the default** because lots of projects used to use `"dev"` as a TLD, but this got registered by google and is now a public suffix.
  - `"error"`: Check and prevent the box from starting. (Does not create the resolver config, it will also prevent the box from starting.)
 
## Using custom domains from inside the VM (VirtualBox only)

If you need to be able to resolve custom domains managed by this plugin from inside your virtual machine (and you're using VirtualBox), add the following
setting to your `Vagrantfile`:

```ruby
Vagrant.configure(2) do |config|
  # ...
  config.vm.provider "virtualbox" do |vm_config, override|
    vm_config.customize [
      "modifyvm", :id,
      "--natdnshostresolver1", "on",
      # some systems also need this:
      # "--natdnshostresolver2", "on"
    ]
  end
end
```

By default, the Virtualbox NAT engine offers the same DNS servers to the guest that are configured on the host. With the above
setting, however, the NAT engine will act as a DNS proxy 
(see [Virtualbox docs](https://www.virtualbox.org/manual/ch09.html#nat-adv-dns)). That way, queries for your custom domains
from inside the guest will also be handled by the DNS server run by the plugin.

## DHCP / Dynamic IP

When configuring your VM with a DHCP network, vagrant-dns tries to identify the guest IP using vagrants build-in `read_ip_address` capability.

For more fine-grained control use the `ip` config.
Here is an example using the VM's default way of communication and using the `hostname` command on it:

```ruby
Vagrant.configure("2") do |config|
  # ...

  # - `vm` is the vagrant virtual machine instance and can be used to communicate with it
  # - `opts` is the vagrant-dns options hash (everything configured via `config.dns.*`)
  config.dns.ip = -> (vm, opts) do
    # note: the block handed to `execute` might get called multiple times, hence this closure
    ip = nil
    vm.communicate.execute("hostname -I | cut -d ' ' -f 1") do |type, data|
      ip = data.strip if type == :stdout
    end
    ip
  end
end
```

__NOTES__: In order to obtain the IP in this way, the vagrant box needs to be up and running. You will get a log output (`Postponing running user provided IP script until box has started.`) when you try to run `vagrant dns`  on a non-running box.

## Issues

* macOS and systemd-resolved enabled Linux only (please read: [Platform Support](https://github.com/BerlinVagrant/vagrant-dns/blob/master/PLATFORM_SUPPORT.md) before ranting about this).
* `A` records only
* No IPv6 support
* Not automatically visible inside the box (special configuration of your guest system or provider needed)
