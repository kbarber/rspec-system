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

Modify you `spec/spec_helper.rb` file (or create one) and add the following setup items:

    RSpec.configure do |config|
      config.system_tmp = File.join(File.dirname(__FILE__), 'system', 'tmp')
      config.system_nodsets = # TODO
    end

### Tests

#### Running tests

Run the system tests with:

    RSPEC_SYSTEM=centos-5-x64 rspec spec/system

#### Writing tests

Create the directory `spec/system` in your project. Add files with the spec prefix ie. `mytests_spec.rb`.
