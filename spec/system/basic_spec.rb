require 'spec_helper_system'

describe "basic tests:" do
  it "check system_run works" do
    system_run("cat /etc/hosts") do |s, o, e|
      s.exitstatus.should == 0
      o.should =~ /localhost/
      e.should == ''
    end
  end
end
