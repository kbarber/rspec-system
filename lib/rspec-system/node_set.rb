module RSpecSystem
  # Factory class for NodeSet.
  class NodeSet
    attr_reader :config, :virtual_env

    # Returns a NodeSet object.
    def self.create(config, virtual_env)
      case(virtual_env)
      when 'vagrant'
        RSpecSystem::NodeSet::Vagrant.new(config)
      else
        raise "Unsupported virtual environment #{virtual_env}"
      end
    end
  end
end

require 'rspec-system/node_set/base'
require 'rspec-system/node_set/vagrant'
