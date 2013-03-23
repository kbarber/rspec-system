require 'rspec-system'
require 'yaml'
require 'pp'
require 'tempfile'

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
    setname = ENV['RSPEC_SET'] || rspec_system_config['default_set']
    config = rspec_system_config['sets'][setname]
    RSpecSystem::NodeSet.create(setname, config, rspec_virtual_env)
  end

  c.system_tmp = Dir.tmpdir
  c.before :suite do
    log.info "START RSPEC-SYSTEM SETUP"
    log.info "Setname is: " + rspec_system_node_set.setname
    log.info "Configuration is: " + rspec_system_node_set.config.pretty_inspect
    log.info "Virtual Environment type is: #{rspec_system_node_set.env_type}"

    rspec_system_node_set.setup
  end

  c.after :suite do
    log.info 'FINALIZE RSPEC-SYSTEM SETUP'
    rspec_system_node_set.teardown
  end
end
