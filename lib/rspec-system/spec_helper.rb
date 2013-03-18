require 'rspec-system'
require 'yaml'
require 'pp'

RSpec.configure do |c|
  include RSpecSystem::Log

  def nodeset
    Pathname.new(File.join(File.basename(__FILE__), '..', '.nodeset.yml'))
  end

  def rspec_system_config
    YAML.load_file('.nodeset.yml')
  end

  # Grab the type of virtual environment we wish to run these tests in
  def rspec_virtual_env
    ENV["RSPEC_VIRTUAL_ENV"] || 'vagrant'
  end

  def rspec_system_node_set
    RSpecSystem::NodeSet.create(rspec_system_config, rspec_virtual_env)
  end

  c.system_tmp = File.join(File.dirname(__FILE__), 'system', 'tmp')
  c.before :suite do
    log.info "START RSPEC-SYSTEM SETUP"
    log.info "Configuration is: " + rspec_system_node_set.config.pretty_inspect
    log.info "Virtual Environment type is: #{rspec_system_node_set.env_type}"

    rspec_system_node_set.setup
  end

  c.after :suite do
    log.info 'FINALIZE RSPEC-SYSTEM SETUP'
    rspec_system_node_set.teardown
  end

  c.before :each do
    log.info 'BEFORE EACH'
    rspec_system_node_set.rollback
  end

  c.after :each do
    log.info 'AFTER EACH'
    rspec_system_node_set.rollback
  end
end
