require 'fileutils'
require 'json'
require 'digest'
require 'fog'

module TaskMonitor
  class S3
    def self.configure(options = {})
      options = {credentials: nil, bucket: nil, jsonp: nil}.merge(options)
      @credentials = options[:credentials]
      @bucket = options[:bucket]
      @jsonp = options[:jsonp]
      self
    end
    
    def self.writeable?
      @credentials and @bucket
    end
  
    def self.write(content = {})
      return unless self.writeable?
      
      json_content = content.to_json
      jsonp_content =<<-JSONP
        #{@jsonp}(#{json_content})
      JSONP
      content_hash = Digest::MD5.hexdigest json_content

      local_path = File.join('/', 'tmp', 'task_monitor')
      FileUtils.mkpath local_path
      if File.exists? File.join(local_path, content_hash)
        Logger.info "Same payload as last time, nothing to update."
        return false
      end
    
      FileUtils.rm_rf Dir.glob("#{local_path}/*")
      FileUtils.touch File.join(local_path, content_hash)
    
      fog = Fog::Storage.new(@credentials)
    
      expire_time = 60*10 # 10 minutes
      fog.directories.get(@bucket).files.create(
        key: 'job_monitor_status.json',
        body: json_content,
        public: true,
        content_type: 'text/json'
      )

      fog.directories.get(@bucket).files.create(
        key: 'job_monitor_status.js',
        body: jsonp_content,
        public: true,
        content_type: 'text/javascript'
      )
    end    
  end
end