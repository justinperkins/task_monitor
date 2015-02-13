module TaskMonitor
  class Logger
    class << self
      def method_missing(m, *args, &block)
        if defined?(Rails) and Rails.logger.respond_to? m
          Rails.logger.send(m, *args)
        else
          puts *args
        end
      end
    end
  end
end