## 2.4.1 (2023-04-16)

* Fix plugin hooking for multi-machine setups. [GH-78]

## 2.4.0 (2023-04-11)

* DHCP support. [GH-51]
* Non-A-queries (like IPv6 AAAA- or TXT records) matching a configured pattern will be answered with a `NOTIMP` error. [GH-76]
* Upstream / passthrough DNS servers are now configurable, defaulting to the system config (existing behavior). [GH-76]
* Passthrough behavior is now configurable (`true`/`false`/`:unknown`). [GH-77]

## 2.3.0 (2023-01-14)

* 🎉 Linux Support. Many thanks @mattiasb [GH-75]
* Managed TLDs are now stored in separate config file, which can be inspected via `vagrant dns --list-ltds`.

## 2.2.3

### Fixes:

* Workaround for a Vargant-on-Ventura issue, crashing the DNS process. [GH-72]

## 2.2.2

### Fixes:

* Installation issue due to updated sub-dependency. [GH-69]

## 2.2.1

### Fixes:

* Prevent action hooks (restarting dns server) from running multiple times [GH-67]

## 2.2.0

### New Features:

* Add global config for time-to-live via `VagrantDNS::Config.ttl`

### Fixes:

* Fixes acceptance tests for macOS High Sierra (10.13) to cope with `scutil`s new output format
* Adds the log-time missing `license` gem config

### Breaking Changes:

* Removes the global and vm config  `ipv4only`. It was never used.

### Changes:

* Resources will now respond with a low TTL (time-to-live) of 5 minutes (300 seconds) instead of the old 24 hours by default. Use `VagrantDNS::Config.ttl = 86400` to reset to the old behavior.
* Internal changes on how the dns pattern config is read and written. (Now using `YAML::Store`)
* Acceptance tests run against vagrant v2.1.4
* Acceptance tests run against Ubuntu 18.04

### New Features:

* Adds a check for the VMs configured TLDs to not be included in the [Public Suffix List](https://publicsuffix.org/)

## 2.1.0

### Breaking, internal changes:

* The version moved from `Vagrant::DNS::VERSION` to `VagrantDNS::VERSION`, removing an accidental highjack of the `Vagrant` namespace.
* The `VagrantDNS::RestartMiddleware` got split up into `VagrantDNS::Middlewares::ConfigUp`, `VagrantDNS::Middlewares::ConfigDown` and `VagrantDNS::Middlewares::Restart`

### Fixes:

* Fixes cli short argument `-S` for `--stop` (collided with `--start`'s `-s`)

### New Feautres:

* Adds new cli command `--status` to display process running status and PID
* Adds new cli command `--list` to display current (persisted) config
* Adds auto-cleanup: Removes registered dns pattern from config when destroying the box. It will, however, be re-created when some box in the project gets re/started or one of vagrant dns `--install`, `--start` or `--restart` is executed.

### Changes:

* The cli command `--stop` no longer re-builds configuration.

## 2.0.0

* Upgrades RubyDNS to `2.0` release

## 2.0.0.rc1

* Upgrades RubyDNS to `2.0.0.pre.rc2`, which removes it's dependency on `celluloid`/`celluloid-dns` 🎉
* Requires Vagrant >= 1.9.6 which ships with ruby 2.3.4 (RubyDNS requires ruby >= 2.2.6)
* Development note: Upgraded to vagrant-share HEAD (d558861f)

## 1.1.0

* Fixes handling of networks without static IP, such as DHCP. [GH-37], [GH-39], [GH-50]
* Add support for boxes with `public_network` and static IP.
* Breaking: No longer falls back to `127.0.0.1` when no IP could be found.
* Log messages will now be tagged with the related box (vm) and `[vagrant-dns]`
* Development targets Vagrant 1.9.3

## 1.0.0

* 🎉Release as 1.0 [GH-34]
* Fixes compatibility to Vagrant 1.7.4 by using RubyDNS ~> 1.0.2 [GH-38]

## 0.6.0

This is a intermediate release towards v1.0.0

* Using RubyDNS ~> 0.9.0
* New option to un/install system files using `sudo` (restoring 0.4 behavior). Add optional `--with-sudo` flag to  `--install`, `--uninstall` or `--purge`. [GH-26]
* Re-add `--ontop` flag. (Start `vagrant-dns` in foreground for debugging)
* Use vagrant >= 1.5 development patterns [GH-31]
* Add acceptance test using vagrant-spec
* Moved sample `Vagrantfile` into `/testdrive` which also contains a small wrapper script `bin/vagrant` to move "vagrant home" into a sandbox.

## 0.5.0

* Use `osascript` to install system files, which require root privileges. [GH-18], [GH-22]
* internal cleanups (@ringods)

## v0.4.1

* Fixes an issue with not configured private networks [GH-21], [GH-19]

## v0.4.0

**This version is not compatible to vagrant < 1.2**

* Supports vagrant 1.2.x [GH-17]
* Update RubyDNS ~> 0.6.0
* Fixes an issue where user-space files got created as root [GH-12]
* Adds command line option `--purge` which deletes the created config file (not only the system symlink to it) [GH-3]

## v0.3.0

* Using RubyDNS ~> 0.5.3

## v0.2.5

* Using RubyDNS 0.4.x

## v0.2.4

* Enable passthrough in DNS service. Helpful if you insist to hook a standard tld like .io.

## v0.2.3

* Remove unneeded iteraton in installers/mac.rb. (thanks to JonathanTron for reporting)
* Fix crash when no tld option was given.

## v0.2.2

* Default to 127.0.0.1 when no network option is given
* Warn if no default pattern is configured because TLD is given, but no host_name

## v0.2.1

* Fix a crash when /etc/resolver is not present

## v0.2.0

* Deactivate ipv6 support (was broken anyways)
* Add multiple patterns support
* Introduces the `tlds` config key, for managing multiple tlds. `tld` is still supported
* --ontop option to run the dns server on top
* removed the logger config in favor of a default logger
* Uses one central server now
* The DNS server is now reconfigured on every run

## v0.1.0

* Initial Release
* Support for A and AAAA configuration
