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
rake acceptance:virtualbox
```
