require 'rspec'

module RSpecSystem; end

require 'rspec-system/log'
require 'rspec-system/helpers'
require 'rspec-system/node_set'

RSpec::configure do |c|
  c.include RSpecSystem::Helpers

  # This provides a path to save vagrant files
  c.add_setting :system_tmp
  # Node set configuration
  c.add_setting :system_nodesets
end
