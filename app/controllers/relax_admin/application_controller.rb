module RelaxAdmin
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    before_action :set_locale
    helper Rails.application.routes.url_helpers

    def current_ability
      @current_ability ||= RelaxAdmin::AdminAbility.new(current_admin)
    end

    private

      def set_locale
        I18n.locale = http_accept_language.compatible_language_from(I18n.available_locales)
      end
  end
end
