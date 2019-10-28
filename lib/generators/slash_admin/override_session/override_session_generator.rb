# frozen_string_literal: true

module SlashAdmin
  module Generators
    class OverrideSessionGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def override_session
        template "session.erb",
          "app/controllers/slash_admin/security/sessions_controller.rb"
      end
    end
  end
end
