module RelaxAdmin
  class ApplicationController < ActionController::Base
    before_action :authenticate_admin!
    helper Rails.application.routes.url_helpers
  end
end
