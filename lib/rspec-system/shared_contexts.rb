require 'logger'

shared_context "rspec-system", :scope => :all do
  extend RSpecSystem::Log
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

  let(:rspec_system_logger) do
    Logger::DEBUG
  end

  before :all do
    require 'pp'

    log.info "START RSPEC-SYSTEM SETUP"
    log.info "Configuration is: " + rspec_system_node_set.config.pretty_inspect
    log.info "Virtual Environment type is: #{rspec_system_node_set.env_type}"

    rspec_system_node_set.setup
  end

  before :each do
    log.info 'BEFORE EACH'
    rspec_system_node_set.rollback
  end

  after :each do
    log.info 'AFTER EACH'
    rspec_system_node_set.rollback
  end

  after :suite do
    log.info 'FINALIZE RSPEC-SYSTEM SETUP'
    rspec_system_node_set.teardown
  end
end
