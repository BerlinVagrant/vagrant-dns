# 1.1.0

* Fixes handling of networks without static IP, such as DHCP. [GH-37], [GH-39], [GH-50]
* Add support for boxes with `public_network` and static IP.
* Breaking: No longer falls back to `127.0.0.1` when no IP could be found.
* Log messages will now be tagged with the related box (vm) and `[vagrant-dns]`
* Develepment targets Vagrant 1.9.3

# 1.0.0

* 🎉Release as 1.0 [GH-34]
* Fixes compatibility to Vagrant 1.7.4 by using RubyDNS ~> 1.0.2 [GH-38]

# 0.6.0

This is a intermediate release towards v1.0.0

* Using RubyDNS ~> 0.9.0
* New option to un/install system files using `sudo` (restoring 0.4 behavior). Add optional `--with-sudo` flag to  `--install`, `--uninstall` or `--purge`. [GH-26]
* Re-add `--ontop` flag. (Start `vagrant-dns` in foreground for debugging)
* Use vagrant >= 1.5 development patterns [GH-31]
* Add acceptance test using vagrant-spec
* Moved sample `Vagrantfile` into `/testdrive` which also contains a small wrapper script `bin/vagrant` to move "vagrant home" into a sandbox.

# 0.5.0

* Use `osascript` to install system files, which require root privileges. [GH-18], [GH-22]
* internal cleanups (@ringods)

# v0.4.1

* Fixes an issue with not configured private networks [GH-21], [GH-19]

# v0.4.0

**This version is not compatible to vagrant < 1.2**

* Supports vagrant 1.2.x [GH-17]
* Update RubyDNS ~> 0.6.0
* Fixes an issue where user-space files got created as root [GH-12]
* Adds command line option `--purge` which deletes the created config file (not only the system symlink to it) [GH-3]

# v0.3.0

* Using RubyDNS ~> 0.5.3

# v0.2.5

* Using RubyDNS 0.4.x

# v0.2.4

* Enable passthrough in DNS service. Helpful if you insist to hook a standard tld like .io.

# v0.2.3

* Remove unneeded iteraton in installers/mac.rb. (thanks to JonathanTron for reporting)
* Fix crash when no tld option was given.

# v0.2.2

* Default to 127.0.0.1 when no network option is given
* Warn if no default pattern is configured because TLD is given, but no host_name

# v0.2.1

* Fix a crash when /etc/resolver is not present

# v0.2.0

* Deactivate ipv6 support (was broken anyways)
* Add multiple patterns support
* Introduces the `tlds` config key, for managing multiple tlds. `tld` is still supported
* --ontop option to run the dns server on top
* removed the logger config in favor of a default logger
* Uses one central server now
* The DNS server is now reconfigured on every run

# v0.1.0

* Initial Release
* Support for A and AAAA configuration
