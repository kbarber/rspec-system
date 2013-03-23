require 'fileutils'

module RSpecSystem
  # A NodeSet implementation for Vagrant.
  class NodeSet::Vagrant < RSpecSystem::NodeSet::Base
    include RSpecSystem::Log

    ENV_TYPE = 'vagrant'

    def initialize(config)
      super
      @vagrant_path = File.expand_path(File.join(RSpec.configuration.system_tmp, 'vagrant_projects', @config["id"].to_s))
    end

    # Setup the NodeSet by starting all nodes.
    def setup
      log.info "Begin setting up vagrant"
      create_vagrantfile

      log.info "Running 'vagrant destroy'"
      vagrant("destroy", "--force")

      log.info "Running 'vagrant up'"
      vagrant("up")
    end

    # Shutdown the NodeSet by shutting down or pausing all nodes.
    def teardown
      log.info "Running 'vagrant destroy'"
      vagrant("destroy", "--force")
    end

    # Run a command on a host in the NodeSet.
    def run(dest, command)
      result = ""
      Dir.chdir(@vagrant_path) do
        result = `vagrant ssh #{dest} --command 'cd /tmp && #{command}'`
      end
      result
    end

    # Create the Vagrantfile for the NodeSet.
    # @api private
    def create_vagrantfile
      log.info "Creating vagrant file here: #{@vagrant_path}"
      FileUtils.mkdir_p(@vagrant_path)
      File.open(File.expand_path(File.join(@vagrant_path, "Vagrantfile")), 'w') do |f|
        f.write('Vagrant::Config.run do |c|')
        @config['nodes'].each do |k,v|
          log.debug "Filling in content for #{k}"
          f.write(<<-EOS)
  c.vm.define '#{k}' do |vmconf|
#{template_prefabs(v["prefab"])}
  end
          EOS
        end
        f.write('end')
      end
      log.debug "Finished creating vagrant file"
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

    # Execute vagrant command in vagrant_path
    # @api private
    def vagrant(*args)
      Dir.chdir(@vagrant_path) do
        system("vagrant", *args)
      end
    end
  end
end
