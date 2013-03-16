require "rspec/core/formatters/base_text_formatter"

module RSpecSystem
  class Formatter < RSpec::Core::Formatters::BaseTextFormatter
    def initialize(output)
      super(output)
    end

    def example_started(proxy)
      output << "\n-------\n"
      output << "Current test: " << proxy.description << "\n"
      output << "-------\n\n"
    end
  end
end
