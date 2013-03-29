# This module contains the main rspec helpers that are to be used within
# rspec-system tests.
module RSpecSystem::Helpers

  # Runs a shell command on a test host
  def run_on(dest, command)
    log.info("run_on(#{dest}, #{command}) executed")
    status, stdout, stderr = rspec_system_node_set.run(dest, command)
    log.info("run_on(#{dest}, #{command}) results:\n" +
      "-----------------------\n" +
      "Exit Status: #{status.exitstatus}\n" +
      "<stdout>#{stdout}</stdout>\n" +
      "<stderr>#{stderr}</stderr>\n" +
      "-----------------------\n")
    [status, stdout, stderr]
  end

end
