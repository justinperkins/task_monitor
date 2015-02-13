module TaskMonitor
  class Monitor
    def self.setup(options = {})
      @options = {
        redis: nil,
        s3: nil,
        slack: nil,
        jsonp: 'sysops.callback'
      }.merge(options)

      @redis = TaskMonitor::Redis.configure(@options[:redis])
      @s3 = TaskMonitor::S3.configure(@options[:s3].merge(jsonp: options[:jsonp])) unless @options[:s3].nil?
      @slack = TaskMonitor::Slack.configure(@options[:slack]) unless @options[:slack].nil?
      self
    end
    
    def self.redis
      @redis
    end

    def self.with_job(job, &block)
      @previous_job = @job
      @previous_alert = @alert
      @job = TaskMonitor::Job.new job
      @alert = TaskMonitor::Alert.new redis: @redis, slack: @slack, job: @job
      yield
    ensure
      @job = @previous_job
      @alert = @previous_alert
    end
    
    def self.alive
      @redis.set @job.alive_key, TaskMonitor::Timestamp.now_formatted
    end

    def self.alert(message)
      @alert.set message
    end

    def self.clear_alert
      @alert.clear
    end

    def self.slack(message)
      @slack.talk message, '#dev'
    end

    def self.report
      statuses = (@redis.keys("#{TaskMonitor::Job.alive_key_prefix}*") || []).inject({}) do |memo, key|
        job_name = key.gsub TaskMonitor::Job.alive_key_prefix, ''
        memo[job_name] = @redis.get(key)
        memo
      end
      alerts = (@redis.keys("#{TaskMonitor::Alert.key_prefix}*") || []).inject({}) do |memo, key|
        job_name = key.gsub TaskMonitor::Alert.key_prefix, ''
        memo[job_name] = @redis.get(key)
        memo
      end
      data = {statuses: statuses, alerts: alerts}
      @s3.write data
      data
    end
  end
end