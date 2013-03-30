module RSpecSystem
  # Base class for a NodeSet driver. If you want to create a new driver, you
  # should sub-class this and override all the methods below.
  #
  # @abstract Subclass and override methods to create a new NodeSet variant.
  class NodeSet::Base
    attr_reader :config
    attr_reader :setname
    attr_reader :nodes

    # Create new NodeSet, populating necessary data structures.
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
    def run(options)
      raise "Unimplemented method #run"
    end

    # Copy a file to the host in the NodeSet.
    def rcp(options)
      raise "Unimplemented method #rcp"
    end

    # Return environment type
    def env_type
      self.class::ENV_TYPE
    end

    # Return default node
    #
    # @return [RSpecSystem::Node] default node for this nodeset
    def default_node
      dn = config['default_node']
      if dn.nil?
        if nodes.length == 1
          dn = nodes.first[1]
          return dn
        else
          raise "No default node"
        end
      else
        return nodes[dn]
      end
    end
  end
end
