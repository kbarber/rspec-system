require 'rspec-system/spec_helper'

module LocalHelpers
  def proj_root
    Pathname.new(File.expand_path(File.join(File.dirname(__FILE__), '..')))
  end

  def fixture_root
    proj_root + 'spec' + 'fixtures'
  end
end

RSpec.configure do |c|
  c.include RSpecSystem::Helpers
  c.include ::LocalHelpers
end
