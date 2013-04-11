require 'spec_helper_system'

describe "basic tests:" do
  it "check system_run works" do
    system_run("cat /etc/hosts") do |r|
      r[:exit_code].should == 0
      r[:stdout].should =~ /localhost/
    end
  end
end
