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
      log.info "[Vagrant#setup] Begin setting up vagrant"
      create_vagrantfile

      log.info "[Vagrant#setup] Running 'vagrant destroy'"
      vagrant("destroy --force")

      log.info "[Vagrant#setup] Running 'vagrant up'"
      vagrant("up")
    end

    # Shutdown the NodeSet by shutting down or pausing all nodes.
    def teardown
      log.info "[Vagrant#teardown] Running 'vagrant destroy'"
      vagrant("destroy --force")
    end

    # Run a command on a host in the NodeSet.
    #
    # @param opts [Hash] options
    def run(opts)
      #log.debug("[Vagrant#run] called with #{opts.inspect}")

      dest = opts[:n].name
      cmd = opts[:c]

      r = nil
      Dir.chdir(@vagrant_path) do
        cmd = "vagrant ssh #{dest} --command \"cd /tmp && sudo #{cmd}\""
        log.debug("[vagrant#run] Running command: #{cmd}")
        r = systemu cmd
        log.debug("[Vagrant#run] Finished running command: #{cmd}.")
      end

      {
        :exit_code => r[0].exitstatus,
        :stdout => r[1],
        :stderr => r[2]
      }
    end

    # Transfer files to a host in the NodeSet.
    #
    # @param opts [Hash] options
    # @todo This is damn ugly, because we ssh in as vagrant, we copy to a temp
    #   path then move it later. Its slow and brittle and we need a better
    #   solution. Its also very Linux-centrix in its use of temp dirs.
    # @todo Need to return more interesting information, not just the systemu
    #   results. This will require a formalisation of this API.
    def rcp(opts)
      #log.debug("[Vagrant@rcp] called with #{opts.inspect}")

      dest = opts[:d].name
      source = opts[:sp]
      dest_path = opts[:dp]

      log.info("[Vagrant#rcp] Transferring files from #{source} to #{dest}:#{dest_path}")

      # Grab a remote path for temp transfer
      tmpdest = tmppath

      # Do the copy and print out results for debugging
      cmd = "scp -r -F '#{ssh_config}' '#{source}' #{dest}:#{tmpdest}"
      log.debug("[Vagrant#rcp] Running command: #{cmd}")
      r = systemu cmd

      result = {
        :exit_code => r[0].exitstatus,
        :stdout => r[1],
        :stderr => r[2]
      }

      log.info("system_run results:\n" +
        "-----------------------\n" +
        result.pretty_inspect +
        "-----------------------\n")

      # Now we move the file into their final destination
      run(:n => opts[:d], :c => "mv #{tmpdest} #{dest_path}")
    end

    # Create the Vagrantfile for the NodeSet.
    #
    # @api private
    def create_vagrantfile
      log.info "[Vagrant#create_vagrantfile] Creating vagrant file here: #{@vagrant_path}"
      FileUtils.mkdir_p(@vagrant_path)
      File.open(File.expand_path(File.join(@vagrant_path, "Vagrantfile")), 'w') do |f|
        f.write('Vagrant::Config.run do |c|')
        nodes.each do |k,v|
          log.debug "Filling in content for #{k}"
          f.write(<<-EOS)
  c.vm.define '#{k}' do |vmconf|
    vmconf.vm.host_name = "#{k}"
#{template_node(v.provider_specifics['vagrant'])}
  end
          EOS
        end
        f.write('end')
      end
      log.debug "[Vagrant#create_vagrantfile] Finished creating vagrant file"
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
      self.nodes.each do |k,v|
        Dir.chdir(@vagrant_path) do
          result = systemu("vagrant ssh-config #{k} >> #{ssh_config_path}")
          puts result.inspect
        end
      end
      ssh_config_path
    end

    # Provide Vagrantfile templates from node definition.
    #
    # @api private
    # @param settings [Hash] provider specific settings for vagrant
    def template_node(settings)
      template = <<-EOS
    vmconf.vm.box = '#{settings['box']}'
    vmconf.vm.box_url = '#{settings['box_url']}'
      EOS
    end

    # Execute vagrant command in vagrant_path
    #
    # @api private
    # @param args [String] args to vagrant
    # @todo This seems a little too specific these days, might want to
    #   generalize. It doesn't use systemu, because we want to see the output
    #   immediately, but still - maybe we can make systemu do that.
    def vagrant(args)
      Dir.chdir(@vagrant_path) do
        system("vagrant #{args}")
      end
      nil
    end

    # Return a random string of chars, used for temp dir creation
    #
    # @api private
    # @return [String] string of 50 random characters A-Z and a-z
    def random_string
      o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
      (0...50).map{ o[rand(o.length)] }.join
    end

    # Generates a random string for use in remote transfers.
    #
    # @api private
    # @return [String] a random path
    # @todo Very Linux dependant, probably need to consider OS X and Windows at
    #   least.
    def tmppath
      '/tmp/' + random_string
    end
  end
end
