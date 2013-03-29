# This module contains the main rspec helpers that are to be used within
# rspec-system tests.
module RSpecSystem::Helpers

  # Runs a shell command on a test host, returning status, stdout and stderr.
  #
  # When invoked as a block the status,stdout and stderr are yielded to the
  # block as parameters.
  #
  # @param dest [String] host to execute command on
  # @param command [String] command to execute
  # @param options [Hash] options for command execution
  # @yield [status, stdout, stderr] yields status, stdout and stderr when
  #   called as a block
  # @yieldparam status [Process::Status] the status of the executed command
  # @yieldparam stdout [String] the standard out of the command result
  # @yieldparam stderr [String] the standard error of the command result
  # @return [Array<Process::Status,String,String>] returns status, stdout and
  #  stderr when called as a simple method.
  def run_on(dest, command, options = {})
    log.info("run_on(#{dest}, #{command}) executed")
    status, stdout, stderr = result = rspec_system_node_set.run(dest, command)
    log.info("run_on(#{dest}, #{command}) results:\n" +
      "-----------------------\n" +
      "Exit Status: #{status.exitstatus}\n" +
      "<stdout>#{stdout}</stdout>\n" +
      "<stderr>#{stderr}</stderr>\n" +
      "-----------------------\n")

    if block_given?
      yield(*result)
    else
      result
    end
  end

end
