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
  def run(dest, command, options = {})
    log.info("run(#{dest}, #{command}) executed")
    status, stdout, stderr = result = rspec_system_node_set.run(dest, command)
    log.info("run(#{dest}, #{command}) results:\n" +
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

  # Remotely copy contents to a destination node and path.
  #
  # @param dest [String] node to execute command on
  # @param source [String] source path to copy
  # @param dest_path [String] destination path to copy to
  # @param options [Hash] options for command execution
  # @yield [status, stdout, stderr] yields status, stdout and stderr when
  #   called as a block
  # @yieldparam status [Process::Status] the status of the executed command
  # @yieldparam stdout [String] the standard out of the command result
  # @yieldparam stderr [String] the standard error of the command result
  # @return [Array<Process::Status,String,String>] returns status, stdout and
  #  stderr when called as a simple method.
  def rcp(dest, source, dest_path, options = {})
    log.info("rcp(#{dest}, #{source}, #{dest_path}) executed")
    status, stdout, stderr = results = rspec_system_node_set.rcp(dest, source, dest_path)
    log.info("rcp(#{dest}, #{source}, #{dest_path}) results:\n" +
      "-----------------------\n" +
      "Exit Status: #{status.exitstatus}\n" +
      "<stdout>#{stdout}</stdout>\n" +
      "<stderr>#{stderr}</stderr>\n" +
      "-----------------------\n")

    results
  end

  # Returns a particular node object from the current nodeset given a set of
  # criteria.
  #
  # @param options [Hash] search criteria
  # @option options [String] :name the canonical name of the node
  # @return [RSpecSystem::Node] node object
  def node(options = {})
    if !options[:name].nil?
      return rspec_system_node_set.nodes[options[:name]]
    elsif rspec_system_node_set.nodes.length == 1
      return rspec_system_node_set.nodes.first
    elsif rspec_system_node_set.nodes.length == 0
      raise "No nodes found?"
    else
      raise "Cannot find node, provide a better search: #{options}"
    end
  end
end
