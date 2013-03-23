module RSpecSystem
  # Base class for a NodeSet.
  class NodeSet::Base
    attr_reader :config, :setname

    def initialize(setname, config)
      @setname = setname
      @config = config
    end

    # Setup the NodeSet by starting all nodes.
    def setup
    end

    # Shutdown the NodeSet by shutting down or pausing all nodes.
    def teardown
    end

    # Take a snapshot of the NodeSet for rollback later.
    def snapshot
    end

    # Rollback to the snapshot of the NodeSet.
    def rollback
    end

    # Run a command on a host in the NodeSet.
    def run(dest, command)
    end

    # Return environment type
    def env_type
      self.class::ENV_TYPE
    end
  end
end
