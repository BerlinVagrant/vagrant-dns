# Development Guidelines

TODO: Expand this section :)

The `Gemfile` uses two environment variables, `TEST_RUBY_VERSION` and `TEST_VAGRANT_VERSION` to control which version of ruby and vagrant are used during local development.

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
