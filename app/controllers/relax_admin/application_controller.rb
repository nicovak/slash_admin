module RelaxAdmin
  class ApplicationController < ActionController::Base
    before_action :authenticate_admin!
    helper Rails.application.routes.url_helpers

    def current_ability
      @current_ability ||= RelaxAdmin::AdminAbility.new(current_admin)
    end
  end
end
