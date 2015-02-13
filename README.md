# in initializer
TaskMonitor.setup SafeRedis, 
                 s3: {credentials: CarrierWave::Uploader::Base.fog_credentials, bucket: Rails.application.config.assets_storage},
                 :slack => {callback_url: MrConfig.slack(:callback_url), MrConfig.slack(:token)}
