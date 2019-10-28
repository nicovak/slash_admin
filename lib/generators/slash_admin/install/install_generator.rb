# frozen_string_literal: true

module SlashAdmin
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def install
        template "install.erb",
          "app/helpers/slash_admin/menu_helper.rb"
      end
    end
  end
end
