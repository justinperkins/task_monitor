module TaskMonitor
  class Slack
    # ripped from ERB::Util in Rails ActiveSupport
    JSON_ESCAPE = { '&' => '\u0026', '>' => '\u003e', '<' => '\u003c', "\u2028" => '\u2028', "\u2029" => '\u2029' }
    JSON_ESCAPE_REGEXP = /[\u2028\u2029&><]/u

    def self.configure(options = {})
      options = {callback_url: nil, token: nil}.merge(options)
      @callback_url = options[:callback_url]
      @token = options[:token]
      self
    end
  
    def self.talkable?
      @callback_url and @token
    end
  
    def self.talk(message, channel = '#dev')
      return unless self.talkable?

      TaskMonitor::Logger.info "Talking to slack on #{channel}"

      uri = URI.parse(@callback_url)
      https = Net::HTTP.new(uri.host,uri.port)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req = Net::HTTP::Post.new(uri.path)
      req.body = "token=#{@token}&payload={\"text\":\"#{json_escape(message)}\"\, \"channel\":\"#{channel}\"}"
      res = https.request(req)
      TaskMonitor::Logger.info "Slack responded (#{res.code}): #{res.body}"
    end
    
    class << self
      private
      def json_escape(message)
        # ripped from ERB::Util in Rails ActiveSupport
        message.to_s.gsub(JSON_ESCAPE_REGEXP, JSON_ESCAPE)
      end
    end
  end
end