require 'spec_helper'

describe "test3 - some failures" do
  include_context 'rspec-system'

  it 'should fail with exception' do
    raise 'my exception'
  end

  pending 'test out pending messages'

  it 'should fail with matcher failure' do
    true.should be_false
  end
end
