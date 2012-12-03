# v0.3.0

* Using RubyDNS v0.5.x

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