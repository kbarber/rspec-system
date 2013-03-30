# This module contains the main rspec helpers that are to be used within
# rspec-system tests. These are the meat-and-potatoes of your system tests,
# and in theory there shouldn't be anything you can't do without the helpers
# here.
#
# These helpers in particular are core to the framework. You can however
# combine these helpers to create your own more powerful helpers in rspec
# if you wish.
#
# @example Using run within your tests
#   describe 'test running' do
#     it 'run cat' do
#       system_run 'cat /etc/resolv.conf' do |s, o, e|
#         s.exitstatus.should == 0
#         o.should =~ /localhost/
#       end
#     end
#   end
# @example Using rcp in your tests
#   describe 'test running' do
#     it 'copy my files' do
#       system_rcp :sp => 'mydata', :dp => '/srv/data'.should be_true
#     end
#   end
# @example Using node in your tests
#   describe 'test running' do
#     it 'do something if redhat' do
#       if system_node.facts[:operatingsystem] == 'RedHat' do
#         system_run 'cat /etc/redhat-release'
#       end
#     end
#   end
# @example Make your own helper
#   describe 'my own helper' do
#     def install_puppet
#       # Grab PL repository and install PL copy of puppet
#       if facts['osfamily'] == 'RedHat'
#         system_run('rpm -ivh http://yum.puppetlabs.com/el/5/products/i386/puppetlabs-release-5-6.noarch.rpm')
#         system_run('yum install -y puppet')
#       elsif facts['osfamily'] == 'Debian'
#         system_run("wget http://apt.puppetlabs.com/puppetlabs-release-#{facts['lsbdistcodename']}.deb")
#         system_run("dpkg -i puppetlabs-release-#{facts['lsbdistcodename']}.deb")
#         system_run('apt-get update')
#         system_run('apt-get install -y puppet')
#       end
#     end
#
#     it 'test installing latest puppet' do
#       install_puppet
#       run_system('puppet apply --version') do |s, o, e|
#         s.exitstatus == 0
#         o.should =~ /3.1/
#         e.should == ''
#       end
#     end
#   end
module RSpecSystem::Helpers
  # @!group Actions

  # Runs a shell command on a test host, returning status, stdout and stderr.
  #
  # When invoked as a block the status,stdout and stderr are yielded to the
  # block as parameters.
  #
  # If you have only provided 1 node in your nodeset, or you have specified a
  # a default you can avoid entering the name of the node if you wish.
  #
  # @api public
  # @param options [Hash, String] options for command execution, if passed a
  #   string it will just use that for the command instead as a convenience.
  # @option options [String] :command command to execute. Mandatory.
  # @option options [String] :c alias for :command
  # @option options [RSpecSystem::Node] :node (defaults to what was defined
  #   default in your YAML file, otherwise if there is only one node it uses
  #   that) specifies node to execute command on.
  # @option options [RSpecSystem::Node] :n alias for :node
  # @yield [status, stdout, stderr] yields status, stdout and stderr when
  #   called as a block.
  # @yieldparam status [Process::Status] the status of the executed command
  # @yieldparam stdout [String] the standard out of the command result
  # @yieldparam stderr [String] the standard error of the command result
  # @return [Array<Process::Status,String,String>] returns status, stdout and
  #  stderr when called as a simple method.
  def system_exec(options)
    ns = rspec_system_node_set
    dn = ns.default_node

    # Take options as a string instead
    if options.is_a?(String)
      options = {:c => options}
    end

    options = {
      :node => options[:n] || dn,
      :n => options[:node] || dn,
      :c => options[:command],
      :command => options[:c],
    }.merge(options)

    if options[:c].nil?
      raise "Cannot use run with no :command option"
    end

    log.info("run #{options[:c]} on #{options[:n].name} executed")
    status, stdout, stderr = result = ns.run(options)
    log.info("run results:\n" +
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

  # Remotely copy files to a test node. This will use the underlying nodes
  # rcp mechanism to do the transfer for you, so you generally shouldn't
  # need to consider the implementation.
  #
  # Just specify a source, and a destination path, and go.
  #
  # @example Remote copy /srv/data to remote host
  #   rcp(:dest_path => '/srv/data', :source_path => 'mydata')
  # @param options [Hash] options for command execution
  # @option options [String] :source_path source to copy files from (currently
  #    only locally)
  # @option options [String] :sp alias for source_path
  # @option options [String] :destination_path destination for copy
  # @option options [String] :dp alias for dest_path
  # @option options [RSpecSystem::Node] :destination_node (default_node) destination node 
  #   to transfer files to. Optional.
  # @option options [RSpecSystem::Node] :d alias for destination_node
  # @option options [RSpecSystem::Node] :source_node ('') Reserved
  #   for future use. Patches welcome.
  # @option options [RSpecSystem::Node] :s alias for source_node
  # @return [Bool] returns true if successful
  # @todo Need to create some helpers for validating input and creating default,
  #   aliases and bloody yarddocs from some other magic format. Ideas?
  # @todo Support system to system copy using source_node option.
  def system_rcp(options)
    options = {
      :source_path => options[:sp],
      :destination_path => options[:dp],
      :dp => options[:destination_path],
      :sp => options[:source_path],
      :destination_node => rspec_system_node_set.default_node,
      :d => rspec_system_node_set.default_node,
      :source_node => '',
      :s => '',
    }.merge(options)

    d = options[:d]
    sp = options[:sp]
    dp = options[:dp]

    log.info("rcp from #{sp} to #{d.name}:#{dp} executed")
    status, stdout, stderr = results = rspec_system_node_set.rcp(options)
    log.info("rcp results:\n" +
      "-----------------------\n" +
      "Exit Status: #{status.exitstatus}\n" +
      "<stdout>#{stdout}</stdout>\n" +
      "<stderr>#{stderr}</stderr>\n" +
      "-----------------------\n")

    if status.exitstatus == 1
      return true
    else
      return false
    end
  end

  # @!group Queries

  # Returns a particular node object from the current nodeset given a set of
  # criteria.
  #
  # If no options are supplied, it tries to return the default node.
  #
  # @param options [Hash] search criteria
  # @option options [String] :name the canonical name of the node
  # @return [RSpecSystem::Node] node object
  def system_node(options = {})
    ns = rspec_system_node_set
    options = {
      :name => ns.default_node,
    }.merge(options)

    if !options[:name].nil?
      return ns.nodes[options[:name]]
    else
      raise "No nodes to return"
    end
  end
end
