module RSpecSystem::Helpers
  def run_on(dest, command)
    log.info("run_on(#{dest}, #{command}) executed")
    result = rspec_system_node_set.run(dest, command)
    log.info("run_on(#{dest}, #{command})\n  result:\n#{result}")
    result
  end
end
