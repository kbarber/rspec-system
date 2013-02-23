require 'system_spec_helper'

shared_examples "test1", :scope => :all do
  it 'run test1 - part1' do
    puts 'test1 - part1'
    run_on('main', "cat /etc/resolv.conf")
  end

  it 'run test1 - part2' do
    puts 'test1 - part2'
    run_on('main', "cat /etc/issue")
  end
end
