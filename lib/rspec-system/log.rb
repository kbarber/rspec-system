module RSpecSystem::Log
  def log
    return @logger if @logger
    @logger = Logger.new(STDOUT)
    @logger.progname = 'rspec-system'
    @logger.formatter = Proc.new do |s, t, p, m|
      "#{s}: #{m}\n"
    end
    @logger
  end
end
