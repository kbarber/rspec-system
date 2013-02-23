require 'system_spec_helper'

describe 'Debian 6.0.6 x86_64', :scope => :all do
  let(:rspec_system_config) do 
    {
      :id => 'debian-606-x64',
      :nodes => {
        'main' => {
          :prefab => 'debian-606-x64',
        }
      }
    }
  end
end
