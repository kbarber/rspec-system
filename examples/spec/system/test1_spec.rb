require 'spec_helper'

describe "test1" do
  include_context 'rspec-system'

  it 'run test1 - part1' do
    run_on('main', "cat /etc/resolv.conf")
  end

  it 'run test1 - part2' do
    run_on('main', "cat /etc/issue")
  end
end
