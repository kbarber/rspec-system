# rspec-system

System testing with rspec.

* [Usage](#usage)
    * [Setup](#setup)
* [Tests](#tests)

## Usage

### Setup

#### Gem installation

The intention is that this gem is used within your project as a development library.

Either install `rspec-system` manually with:

    gem install rspec-system

However it is usually recommended to include it in your `Gemfile` and let bundler install it, by adding the following:

    gem 'rspec-system'

Then installing with:

    bundle install

#### Configuration

TODO: for now just look at the `examples` directory.

### Tests

Start by looking at the `examples` directory. I plan on fleshing out this documentation but for now just use the example.

#### Running tests

Run the system tests with:

    rake spec:system

Instead of switches, we use a number of environment variables to modify the behaviour of running tests. This is more inline with the way testing frameworks like Jenkins work, and should be pretty easy for command line users as well:

*RSPEC_VIRTUAL_ENV* - the type of virtual environment to run (currently `vagrant`)
*RSPEC_SET* - the set to use when running tests (defaults to the `default_set` setting in your nodeset file)

#### Writing tests

Create the directory `spec/system` in your project. Add files with the spec prefix ie. `mytests_spec.rb`.
