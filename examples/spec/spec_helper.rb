require 'rspec-system'

RSpec.configure do |c|
  c.system_tmp = File.join(File.dirname(__FILE__), 'system', 'tmp')
end
