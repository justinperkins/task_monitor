require 'tzinfo'

module TaskMonitor
  class Alert
    def self.key_prefix
      "job_alert_"
    end

    def initialize(options = {})
      options = {redis: nil, slack: nil, job: nil}.merge(options)
      @job = options[:job]
      @redis = options[:redis]
      @slack = options[:slack]
      throw 'Redis is required for alerts to function' unless @redis
    end
  
    def activate_job(job)
      @job = job
    end
  
    def set(message)
      return if self.active?
      @redis.set self.key, "#{message} @ #{TaskMonitor::Timestamp.now_formatted}"
      @slack.talk ":tada: FUCK A DUCK!! #{@job.to_s} says: #{message}" if @slack
    end
  
    def clear
      return unless self.active?
      @redis.del self.key
      @slack.talk ":birthday: oh cool the job alert cleared for #{@job.to_s}" if @slack
    end
  
    def active?
      v = @redis.get(self.key)
      v && !v.empty?
    end
  
    def key
      "#{self.class.key_prefix}#{@job.to_s}"
    end
  end
end