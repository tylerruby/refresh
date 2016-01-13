CarrierWave.configure do |config|
  # For now, let the images in development using fog
  # if Rails.env.production? || Rails.env.staging?
  config.fog_credentials = {
    provider:              'AWS',
    aws_access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
    aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    path_style:            true
  }
  config.fog_directory = ENV['AWS_BUCKET_NAME']
  config.asset_host    = "http://#{ENV['AWS_BUCKET_NAME']}.s3.amazonaws.com"
  config.storage       = :fog
  # else
  #   config.enable_processing = false if Rails.env.test?
  #   config.storage = :file
  # end
end

# https://github.com/jnicklas/carrierwave/wiki/How-to%3A-Specify-the-image-quality
module CarrierWave
  module MiniMagick
    def quality(percentage)
      manipulate! do |img|
        img.quality(percentage.to_s)
        img = yield(img) if block_given?
        img
      end
    end
  end
end
