require "rspec/core/formatters/base_text_formatter"

module RSpecSystem
  class Formatter < RSpec::Core::Formatters::BaseTextFormatter
    def initialize(output)
      super(output)
    end

    def start(count)
      super(count)
      output << "=================================================================\n\n"
      output << bold("Commencing rspec-system tests\n")
      output << bold("Total Test Count: ") << color(count, :cyan) << "\n\n"
    end

    def example_started(example)
      super(example)
      output << "=================================================================\n\n"
      output << bold("Running test:\n  ") << color(example.full_description, :magenta) << "\n\n"
    end

    def example_passed(example)
      super(example)
      output << "\n" << bold('Result: ') << success_color('passed') << "\n\n"
    end

    def example_pending(example)
      super(example)
      msg = example.execution_result[:pending_message]
      output << "\n" << bold('Result: ') << pending_color('pending') << "\n"
      output << bold("Reason: ") << "#{msg}\n\n"
    end

    def example_failed(example)
      super(example)
      msg = example.execution_result[:exception]
      output << "\n" << bold('Result: ') << failure_color('failed') << "\n"
      output << bold("Index: ") << "#{next_failure_index}\n"
      output << bold("Reason:\n") << "#{msg}\n\n"
    end

    def next_failure_index
      @next_failure_index ||= 0
      @next_failure_index += 1
    end
  end
end
