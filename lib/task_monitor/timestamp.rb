require 'tzinfo'
module TaskMonitor
  class Timestamp
    def self.now
      tz = TZInfo::Timezone.get 'US/Central'
      tz.now
    end
    
    def self.now_formatted
      self.now.strftime('%Y-%m-%d %H:%M %Z')
    end
  end
end