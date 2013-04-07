require 'rspec-system/spec_helper'

RSpec.configure do |c|
  c.include RSpecSystem::Helpers
  #proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # This is where we 'setup' the nodes before running our tests
  #c.system_setup_block = proc do
  #end
end
