module TaskMonitor
  class Redis
    def self.configure(redis)
      @redis = redis
      self
    end

    class << self
      def method_missing(m, *args, &block)
        puts "m: #{m} and redis: #{@redis}"
        if @redis and @redis.respond_to? m
          @redis.send(m, *args)
        else
          TaskMonitor::Logger.info "Redis not configured"
        end
      end
    end
  end
end