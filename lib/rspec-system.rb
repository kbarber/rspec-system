require 'rspec'

module RSpecSystem; end

require 'rspec-system/log'
require 'rspec-system/helpers'
require 'rspec-system/node_set'
require 'rspec-system/prefab'
require 'rspec-system/node'

RSpec::configure do |c|
  c.include RSpecSystem::Helpers

  # This provides a path to save vagrant files
  c.add_setting :system_tmp
  # Block to execute for environment setup
  c.add_setting :system_setup_block
end
