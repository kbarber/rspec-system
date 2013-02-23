require 'logger'

shared_context "shared stuff", :scope => :all do
  # Grab the type of virtual environment we wish to run these tests in
  let(:rspec_virtual_env) do
    ENV["RSPEC_VIRTUAL_ENV"] || 'vagrant'
  end

  let(:rspec_system_node_set) do
    RSpecSystem::NodeSet.create(rspec_system_config, rspec_virtual_env)
  end

  let(:rspec_system_logger) do
    Logger::DEBUG
  end

  before :all do
    require 'pp'

    puts "Configuration for now is:"
    puts rspec_system_node_set.config.pretty_inspect
    puts "Virtual Environment is: #{rspec_system_node_set.env_type}"

    rspec_system_node_set.setup

    puts 'before all: setup vms'
    puts 'before all: snapshot vms'
  end

  before :each do
    puts 'before each: roll back vms'
    rspec_system_node_set.rollback
  end

  after :each do
    puts 'after each: roll back vms'
    rspec_system_node_set.rollback
  end

  after :all do
    puts 'after all: shut down all vms'
    rspec_system_node_set.teardown
  end
end
