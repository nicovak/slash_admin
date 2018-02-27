# frozen_string_literal: true
module SlashAdmin
  class DashboardController < SlashAdmin::BaseController
    def home; end

    def toggle
      session[:compact] = session[:compact].blank? ? true : nil
      redirect_to request.referer
    end
  end
end
