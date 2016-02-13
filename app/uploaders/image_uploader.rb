class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::MimeTypes

  process :set_content_type

  # https://github.com/jnicklas/carrierwave/wiki/How-to%3A-Specify-the-image-quality
  process quality: 90

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    file_path = [
      'fallbacks',
      [model.class.to_s.underscore, mounted_as, version_name].compact.join('_')
    ].join '/'

    'http://' + ENV['HOST'] + ActionController::Base.helpers.image_path(file_path)
  end

  version :thumb do
    process resize_to_fit: [100, 100]
  end

  version :thumb_fill do
    process resize_to_fill: [150, 150]
  end

  version :medium do
    process resize_to_fit: [300, 300]
  end

  version :medium_fill do
    process resize_to_fill: [300, 300]
  end
end
