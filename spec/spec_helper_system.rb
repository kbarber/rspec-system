require 'rspec-system/spec_helper'

RSpec.configure do |c|
  c.include RSpecSystem::Helpers

  # This is where we 'setup' the nodes before running our tests
  c.system_setup_block = proc do
    facts = system_node.facts

    # Remove annoying mesg n from profile, otherwise on Debian we get:
    # stdin: is not a tty which messes with our tests later on.
    if facts['osfamily'] == 'Debian'
      log.info("Remove 'mesg n' from profile to stop noise")
      system_run("sed -i 's/^mesg n/# mesg n/' /root/.profile")
    end
  end
end
