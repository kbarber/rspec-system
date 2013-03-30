require 'logger'

# This log overlay module, provides access to the +log+ method.
module RSpecSystem::Log
  # Return the default Logger object.
  #
  # @return [Logger] default logger object
  def log
    return @logger if @logger
    @logger = ::Logger.new(STDOUT)
    @logger.progname = 'rspec-system'
    @logger.formatter = Proc.new do |s, t, p, m|
      "#{s}: #{m}\n"
    end
    @logger
  end
end
