# Development Guidelines

TODO: Expand this section :)

The `Gemfile` uses the `TEST_VAGRANT_VERSION` environment variable to control which version of vagrant is used during local development.
To adjust the ruby version used, change the contents of the `.ruby-version` file, even if you don't use a ruby version manager.

## Running Acceptance Tests

This project uses `vagrant-spec` to run acceptance tests.
See `test/acceptance/dns` for spec files and `test/acceptance/skeletons/*` for Vagrantfiles. 
See `tasks/acceptance.rake` for the basic setup of vagrant-spec. This file also defines which base box is used.
Specs will take quite some time and run in GUI mode (due to some weirdness either in vagrant-spec and/or VirtualBox) which will render your machine basically unusable.

```bash
# List available tasks:
bundle exec rake -D acceptance

# Setup specs (download box artifacts)
bundle exec rake acceptance:setup:virtualbox

# Run tests
bundle exec rake acceptance:virtualbox
```

### On other providers

1. If it's not a default provider, add it to to `Gemfile` as a dependency and re-run `bundle install`.
2. Add a box provider name to box URL mapping to the `TEST_BOXES` hash in `tasks/acceptance.rake`
3. Run the `acceptance` rake task like above, replacing `virtualbox` with your provider.


### VMware IPs

VMware uses IPs from its bridges for DHCP and static private networks. Check IP and net masks using:

```console
ifconfig -X bridge | grep 'inet ' | grep -v '127.0.0.1' | awk '{ print $2 "\t" $4 }'
```
