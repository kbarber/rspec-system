module RSpecSystem::Helpers
  def run_on(dest, command)
    log.info("run_on(#{dest}, #{command}) executed")
    result = rspec_system_node_set.run(dest, command)
    log.info("run_on(#{dest}, #{command}) finished\n--result--\n#{result}\n--result--\n")
    result
  end
end
