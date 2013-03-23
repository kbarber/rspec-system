module RSpecSystem
  # Factory class for NodeSet.
  class NodeSet
    # Returns a NodeSet object.
    def self.create(setname, config, virtual_env)
      case(virtual_env)
      when 'vagrant'
        RSpecSystem::NodeSet::Vagrant.new(setname, config)
      else
        raise "Unsupported virtual environment #{virtual_env}"
      end
    end
  end
end

require 'rspec-system/node_set/base'
require 'rspec-system/node_set/vagrant'
