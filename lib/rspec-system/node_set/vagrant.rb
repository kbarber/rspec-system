require 'fileutils'
require 'systemu'

module RSpecSystem
  # A NodeSet implementation for Vagrant.
  class NodeSet::Vagrant < RSpecSystem::NodeSet::Base
    include RSpecSystem::Log

    ENV_TYPE = 'vagrant'

    def initialize(setname, config)
      super
      @vagrant_path = File.expand_path(File.join(RSpec.configuration.system_tmp, 'vagrant_projects', setname))
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
        cmd = "vagrant ssh #{dest} --command \"cd /tmp && sudo -i #{command}\""
        log.debug("[vagrant 'run'] Running command: #{cmd}")
        result = systemu cmd
      end
      result
    end

    # Transfer files to a host in the NodeSet.
    def rcp(dest, source, dest_path)
      # TODO: This is damn ugly, because we ssh in as vagrant, we copy to a
      # temp path then move later. This pattern at the moment only really works
      # on dirs.
      log.info("Transferring files from #{source} to #{dest}:#{dest_path}")

      # TODO: The static temp path here is definately insecure
      cmd = "scp -r -F #{ssh_config} #{source} #{dest}:/tmp/tmpxfer"
      log.debug("Running command: #{cmd}")
      systemu cmd

      # Now we move the file into place
      run(dest, "mv /tmp/tmpxfer #{dest_path}")
    end

    # Create the Vagrantfile for the NodeSet.
    #
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
    vmconf.vm.host_name = "#{k}"
#{template_prefabs(v["prefab"])}
  end
          EOS
        end
        f.write('end')
      end
      log.debug "Finished creating vagrant file"
    end

    # Here we get vagrant to drop the ssh_config its using so we can monopolize
    # it for transfers and custom stuff. We drop it into a single file, and
    # since its indexed based on our own node names its quite ideal.
    #
    # @api private
    def ssh_config
      ssh_config_path = File.expand_path(File.join(@vagrant_path, "ssh_config"))
      begin
        File.unlink(ssh_config_path)
      rescue Errno::ENOENT
      end
      @config['nodes'].each do |k,v|
        Dir.chdir(@vagrant_path) do
          result = systemu("vagrant ssh-config #{k} >> #{ssh_config_path}")
          puts result.inspect
        end
      end
      ssh_config_path
    end

    # Provide Vagrantfile templates for prefabs. We'll need to expand on how
    # this gets done to provide for customisation etc. but for now everything
    # is hard-coded.
    #
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
    #
    # @api private
    def vagrant(*args)
      Dir.chdir(@vagrant_path) do
        system("vagrant", *args)
      end
    end
  end
end
