# frozen_string_literal: true
module RelaxAdmin
  class Security::SessionsController < ActionController::Base
    layout 'relax_admin/admin_user'

    def new
    end

    def create
      admin = Admin.where('username = :value OR lower(email) = lower(:value)', value: params[:admin][:login]).first
      if admin&.authenticate(params[:admin][:password])
        session[:admin_id] = admin.id
        flash[:notice] = 'Vous êtes à présent connecté.'
        redirect_to relax_admin.dashboard_path
      else
        render :new && return
      end
    end

    def destroy
      session[:admin_id] = nil
      flash[:notice] = 'Déconnecté avec succès.'
      render :new
    end
  end
end
