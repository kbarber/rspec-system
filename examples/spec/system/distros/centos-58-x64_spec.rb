require 'system_spec_helper.rb'

describe "Centos 5.8 x86_64", :scope => :all do
  let(:rspec_system_config) do
    {
      :id => 'centos-58-x64',
      :nodes => {
        'main' => {
          :prefab => 'centos-58-x64',
        }
      }
    }
  end
end
