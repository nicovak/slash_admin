# frozen_string_literal: true
module RelaxAdmin
  class ImageUploader < CarrierWave::Uploader::Base
    def extension_white_list
      %w(jpg jpeg gif png)
    end

    def content_type_whitelist
      /image\//
    end
  end
end
