# frozen_string_literal: true

module SlashAdmin
  module Generators
    class ControllersGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)
      argument :model, required: true,
                       desc: "The model concerned"

      def create_controller
        @model_name = model.camelize
        template "controllers.erb",
          "app/controllers/slash_admin/models/#{model}_controller.rb"
      end
    end
  end
end
