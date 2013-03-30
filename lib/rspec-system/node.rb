module RSpecSystem
  # This class represents a node in a nodeset
  class Node
    # @!attribute [r] name
    #   @return [String] name of the node
    attr_reader :name
    # @!attribute [r] prefab
    #   @return [RSpecSystem::Prefab] prefab object if this node has one
    attr_reader :prefab
    # @!attribute [r] nodeset
    #   @return [RSpecSystem::NodeSet] nodeset this node belongs to
    attr_reader :nodeset
    # @!attribute [r] facts
    #   @return [Hash] facter facts for this image, static not real. These are
    #     just a subset of a facter run on the host, useful for making decisions
    #     about a node without needing to interact with it.
    attr_reader :facts

    # Static helper for generating a node direct from the hash returned by
    # the nodeset YAML file.
    #
    # @param nodeset [RSpecSystem::Node] nodeset that this node belongs to
    # @param k [String] name of node
    # @param v [Hash] hash configuration as given from the nodeset yaml file
    # @return [RSpecSystem::Node] returns a new node object
    def self.node_from_yaml(nodeset, k, v)
      RSpecSystem::Node.new(
        :nodeset => nodeset,
        :name => k,
        :prefab => v['prefab']
      )
    end

    # Create a new node object.
    #
    # @param options [Hash] options for new node
    # @option options [String] :name name of node
    # @option options [String] :prefab prefab setting
    # @option options [RSpecSystem::NodeSet] :nodeset the parent nodeset for
    #   this node
    def initialize(options = {})
      @name = options[:name]
      prefab = options[:prefab]
      @nodeset = options[:nodeset]

      if prefab.nil?
        # TODO: do not support not prefabs yet
        raise "No prefab defined, bailing"
      else
        @prefab = RSpecSystem::Prefab.prefab(prefab)
        @facts = @prefab.facts
      end
    end
  end
end
