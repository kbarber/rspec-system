require 'vagrant'
require 'fileutils'

module RSpecSystem
  # A NodeSet implementation for Vagrant.
  class NodeSet::Vagrant < RSpecSystem::NodeSet::Base
    ENV_TYPE = 'vagrant'

    def initialize(config)
      super
      @vagrant_path = File.expand_path(File.join(RSpec.configuration.rspec_system_vagrant_projects, @config[:id].to_s))
    end

    # Setup the NodeSet by starting all nodes.
    def setup
      puts "Setting up vagrant!"
      create_vagrantfile

      puts "prepping vagrant environment"
      @vagrant_env = Vagrant::Environment.new(:cwd => @vagrant_path)
      puts "running vagrant up"
      @vagrant_env.cli("up")

      snapshot
    end

    # Shutdown the NodeSet by shutting down or pausing all nodes.
    def teardown
      puts "running vagrant down"
      @vagrant_env.cli("destroy")
    end

    # Take a snapshot of the NodeSet for rollback later.
    def snapshot
      puts "turning on sandbox"
      Dir.chdir(@vagrant_path) do
        @vagrant_env.cli("sandbox", "on")
      end
    end

    # Rollback to the snapshot of the NodeSet.
    def rollback
      puts "rolling back vagrant box"
      Dir.chdir(@vagrant_path) do
        @vagrant_env.cli("sandbox", "rollback")
      end
    end

    # Run a command on a host in the NodeSet.
    def run(dest, command)
      puts "Running #{command} on #{dest}"
      result = ""
      @vagrant_env.vms[dest.to_sym].channel.sudo("cd /tmp && #{command}") do |ch, data| 
        result << data
        puts "Got data: #{data}"
      end
      result
    end

    # Create the Vagrantfile for the NodeSet.
    # @api private
    def create_vagrantfile
      puts "Creating vagrant file here: #{@vagrant_path}"
      FileUtils.mkdir_p(@vagrant_path)
      File.open(File.expand_path(File.join(@vagrant_path, "Vagrantfile")), 'w') do |f|
        f.write('Vagrant::Config.run do |c|')
        @config[:nodes].each do |k,v|
          puts "prepping #{k}"
          f.write(<<-EOS)
  c.vm.define '#{k}' do |vmconf|
#{template_prefabs(v[:prefab])}
  end
          EOS
        end
        f.write('end')
      end
    end

    # Provide Vagrantfile templates for prefabs.
    # @api private
    def template_prefabs(prefab)
      case prefab
      when 'centos-58-x64'
        <<-EOS
    vmconf.vm.box = 'centos-58-x64'
    vmconf.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/centos-58-x64.box'
        EOS
      when 'debian-606-x64'
        <<-EOS
    vmconf.vm.box = 'debian-606-x64'
    vmconf.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/debian-606-x64.box'
        EOS
      else
        raise 'Unknown prefab'
      end
    end
  end
end
