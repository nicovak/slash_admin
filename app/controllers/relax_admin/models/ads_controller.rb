# frozen_string_literal: true
class Admin::Models::AdsController < Admin::BaseController
  def list_params
    [
      {attr: :image, type: 'image'},
      :title,
    ]
  end

  def export_params
    [
      :title,
    ]
  end
end
