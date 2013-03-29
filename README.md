# rspec-system

`rspec-system` provides a framework for creating system tests using the `rspec` testing library.

The goal here is to provide facilities to aid in the launching of tests nodes, copying of test content to such nodes, and executing commands on such nodes to be tested with standard rspec assertions within the standard rspec test format.

*Note:* This library is fairly alpha at the moment, and the interface may change at without warning. That said, if you're good at ruby and have an opinion, I'd appreciate patches and improvements to move this further torwards stability.

### Gem installation

The intention is that this gem is used within your project as a development library.

Either install `rspec-system` manually with:

    gem install rspec-system

However it is usually recommended to include it in your `Gemfile` and let bundler install it, by adding the following:

    gem 'rspec-system'

Then installing with:

    bundle install

### Writing tests

Start by creating a helper file in `spec/spec_helper_system.rb` containing something like the following:

    require 'rspec-system/spec_helper'

    RSpec.configure do |c|
      c.system_setup_block = proc do
        include RSpecSystem::Helpers
        # Insert some setup tasks here
        run_on('main', 'yum install -y ntp')
      end
    end

Create the directory `spec/system` in your project, make sure your unit tests go into `spec/unit` or somesuch so you can isolate them easily during test time. Add files with the spec prefix ie. `mytests_spec.rb` and make sure they always include the line `require 'spec_helper_system'` eg.:

    require 'spec_helper_system'

    describe 'basics' do
      it 'should cat /etc/resolv.conf' do
        run_on('main', 'cat /etc/resolv.conf') do |status,stdout,stderr|
          stdout.should =~ /localhost/
        end
      end
    end

Also consult the example in `example` in the source of this library for more details.

For you reference, here are the list of custom rspec configuration items that can be overriden in your `spec_helper_system.rb` file:

* *system_setup_block* - this accepts a proc that is called after node setup, but before every test (ie. before suite). The goal of this option is to provide a good place for node setup independant of tests.
* *system_tmp* - For some of our activity, we require a temporary file area. By default we just a random temporary path, so you normally do not need to set this.

Currently to get the nice formatting rspec-system specific formatter its recommended to use the Rake task, so the following to your `Rakefile`:

    require 'rspec-system/rake_task'

That will setup the rake task `rake spec:system`.

### Creating a nodeset file

A nodeset file outlines all the node configurations for your tests. The concept here is to define one or more 'nodesets' each nodeset containing one or more 'nodes'.

    ---
    default_set: 'centos-58-x64'
    sets:
      'centos-58-x64':
        nodes:
          "main":
            prefab: 'centos-58-x64'

The file must adhere to the Kwalify schema supplied in `resources/kwalify-schemas/nodeset_schema.yml`.

Prefabs are 'pre-rolled' virtual images, for now its the only way to do it. I plan on documenting this in more detail, and also allowing for customisation on this level. For now only `centos-58-x64` and `debian-606-x64` are supported.

### Running tests

Run the system tests with:

    rake spec:system

Instead of switches, we use a number of environment variables to modify the behaviour of running tests. This is more inline with the way testing frameworks like Jenkins work, and should be pretty easy for command line users as well:

* *RSPEC_VIRTUAL_ENV* - the type of virtual environment to run (currently `vagrant` is the only option)
* *RSPEC_SET* - the set to use when running tests (defaults to the `default_set` setting in the projects `.nodeset.yml` file)

So if you wanted to run an alternate nodeset you could use:

    RSPEC_SET=nodeset2 rake spec:system

In Jenkins you should be able to use RSPEC\_SET in a test matrix, thus obtaining quite a nice integration and visual display of nodesets in Jenkins.
