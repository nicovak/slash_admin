# frozen_string_literal: true

module SlashAdmin
  module Security
    class SessionsController < ActionController::Base
      protect_from_forgery with: :exception

      layout "slash_admin/admin_user"

      def new
      end

      def create
        admin = Admin.where("username = :value OR lower(email) = lower(:value)", value: params[:admin][:login]).first
        if admin&.authenticate(params[:admin][:password])
          session[:admin_id] = admin.id
          flash[:success] = "Vous êtes à présent connecté."
          redirect_to slash_admin.dashboard_path
        else
          @error_messages = "Merci de vérifier vos identifiants"
          render(:new) && return
        end
      end

      def destroy
        session[:admin_id] = nil
        redirect_to slash_admin.login_url
      end
    end
  end
end
