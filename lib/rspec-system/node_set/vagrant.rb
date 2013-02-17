require 'vagrant'
require 'tempfile'

module RSpecSystem
  class NodeSet::Vagrant
    def initialize(config)
      @config = config
    end

    def setup
      puts "Setting up vagrant!"

      tp = Tempfile.new("vagrant")
      path = tp.path
      tp.close
      tp.unlink

      puts "Creating vagrant file here: #{path}"
      Dir.mkdir(path)
      File.open(File.expand_path(File.join(path, "Vagrantfile")), 'w') do |f|
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
      puts "prepping env"
      vagrant_env = Vagrant::Environment.new(:cwd => path)
      puts "running up"
      vagrant_env.cli("up", "main")
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
