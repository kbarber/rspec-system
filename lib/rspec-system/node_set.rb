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

    def teardown
      @virtual_driver.teardown
    end

    def rollback
      @virtual_driver.rollback
    end

    def run(dest, command)
      @virtual_driver.run(dest,command)
    end
  end
end

require 'rspec-system/node_set/vagrant'
