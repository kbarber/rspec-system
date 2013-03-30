module RSpecSystem
  # Base class for a NodeSet driver. If you want to create a new driver, you
  # should sub-class this and override all the methods below.
  class NodeSet::Base
    attr_reader :config
    attr_reader :setname
    attr_reader :nodes

    def initialize(setname, config)
      @setname = setname
      @config = config

      @nodes = {}
      config['nodes'].each do |k,v|
        @nodes[k] = RSpecSystem::Node.node_from_yaml(self, k, v)
      end
    end

    # Setup the NodeSet by starting all nodes.
    def setup
      raise "Unimplemented method #setup"
    end

    # Shutdown the NodeSet by shutting down or pausing all nodes.
    def teardown
      raise "Unimplemented method #teardown"
    end

    # Run a command on a host in the NodeSet.
    def run(dest, command)
      raise "Unimplemented method #run"
    end

    # Copy a file to the host in the NodeSet.
    def run(dest, command)
      raise "Unimplemented method #rcp"
    end

    # Return environment type
    def env_type
      self.class::ENV_TYPE
    end
  end
end
