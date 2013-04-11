require 'spec_helper_system'

describe "basic tests:" do
  it "check system_run works" do
    system_run("cat /etc/hosts") do |r|
      r[:exit_code].should == 0
      r[:stdout].should =~ /localhost/
    end
  end

  it 'check system_rcp works' do
    system_rcp(
      :sp => fixture_root + 'example_dir',
      :dp => '/tmp/example_destination'
    )

    system_run('cat /tmp/example_destination/example_file') do |r|
      r[:exit_code].should == 0
      r[:stdout].should =~ /Test content 1234/
    end
  end
end
