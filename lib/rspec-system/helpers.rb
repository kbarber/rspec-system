module RSpecSystem::Helpers
  def run_on(dest, command)
    rspec_system_node_set.run(dest,command)
  end
end
