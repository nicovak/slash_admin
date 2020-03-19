module SlashAdmin
  class BaseController < SlashAdmin::ApplicationController
    before_action :authenticate_admin!
    before_action :handle_default
    before_action :handle_default_mode
    before_action :prepend_view_paths
    helper_method :current_admin, :boolean_to_string

    protected

    def handle_default
    end

    def handle_default_mode
      session[:compact] ||= false
    end

    def prepend_view_paths
      prepend_view_path "app/views/slash_admin"
    end

    private

    def authenticate_admin!
      return true if current_admin.present?
      flash[:error] = t("slash_admin.sessions.login_required")
      redirect_to login_url unless controller_name == "sessions"
    end

    def current_admin
      @current_admin ||= SlashAdmin::Admin.find(session[:admin_id]) if session[:admin_id]
    end

    def to_boolean(str)
      str == "true"
    end

    def boolean_to_string(str)
      str ? "true" : "false"
    end

    def should_load_layout_data?
      false
    end
  end
end
