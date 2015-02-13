module TaskMonitor
  class Job
    def self.alive_key_prefix
      "job_alive_"
    end
  
    def initialize(name)
      @name = name
    end
  
    def alive_key
      "#{self.class.alive_key_prefix}#{self.to_s}"
    end
  
    def to_s
      @name
    end
  end
end