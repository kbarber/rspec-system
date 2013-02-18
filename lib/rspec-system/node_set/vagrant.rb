require 'vagrant'
require 'fileutils'

module RSpecSystem
  class NodeSet::Vagrant
    def initialize(config)
      @config = config
      @vagrant_path = File.expand_path(File.join(RSpec.configuration.rspec_system_vagrant_projects, @config[:id].to_s))
    end

    def setup
      puts "Setting up vagrant!"
      create_virtualboxfile

      puts "prepping vagrant environment"
      @vagrant_env = Vagrant::Environment.new(:cwd => @vagrant_path)
      puts "running vagrant up"
      @vagrant_env.cli("up")

      snapshot
    end

    def teardown
      puts "running vagrant down"
      @vagrant_env.cli("suspend")
    end

    def snapshot
      puts "turning on sandbox"
      Dir.chdir(@vagrant_path) do
        @vagrant_env.cli("sandbox", "on")
      end
    end

    def rollback
      puts "rolling back vagrant box"
      Dir.chdir(@vagrant_path) do
        @vagrant_env.cli("sandbox", "rollback")
      end
    end

    def run(dest, command)
      puts "Running #{command} on #{dest}"
      result = ""
      @vagrant_env.vms[dest.to_sym].channel.sudo("cd /tmp && #{command}") do |ch, data| 
        result << data
        puts "Got data: #{data}"
      end
      result
    end

    # @api private
    def create_virtualboxfile
      puts "Creating vagrant file here: #{@vagrant_path}"
      FileUtils.mkdir_p(@vagrant_path)
      File.open(File.expand_path(File.join(@vagrant_path, "Vagrantfile")), 'w') do |f|
        f.write('Vagrant::Config.run do |c|')
        @config[:nodes].each do |k,v|
          puts "prepping #{k}"
          f.write(<<-EOS)
  c.vm.define '#{k}' do |vmconf|
#{setup_prefabs(v[:prefab])}
  end
          EOS
        end
        f.write('end')
      end
    end

    # @api private
    def setup_prefabs(prefab)
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
