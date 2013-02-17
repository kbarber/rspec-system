module RSpecSystem
  class NodeSet
    attr_reader :config, :virtual_env

    def initialize(config, virtual_env)
      @config = config
      @virtual_env = virtual_env

      @virtual_driver = case(@virtual_env)
      when 'vagrant'
        RSpecSystem::NodeSet::Vagrant.new(@config)
      else
        raise "Unsupported virtual environment #{@virtual_env}"
      end
    end

    def setup
      @virtual_driver.setup
    end
  end
end

require 'rspec-system/node_set/vagrant'
