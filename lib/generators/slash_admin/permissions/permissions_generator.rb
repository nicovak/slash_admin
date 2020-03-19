# frozen_string_literal: true

module SlashAdmin
  module Generators
    class PermissionsGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def create_permissions
        template "permissions.erb",
          "app/models/slash_admin/admin_ability.rb"
      end
    end
  end
end
