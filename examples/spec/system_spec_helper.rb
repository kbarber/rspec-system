require 'rspec-system'
require 'system/tests/test1'
require 'system/tests/test2'

RSpec.configure do |c|
  c.rspec_system_vagrant_projects = File.join(File.dirname(__FILE__), 'system', 'tmp', 'rspec_system_vagrant')
end
