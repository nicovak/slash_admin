# frozen_string_literal: true
module RelaxAdmin
  module Generators
    class PermissionsGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def create_controller
        template 'permissions.erb',
                 'app/models/relax_admin/admin_ability.rb'
      end
    end
  end
end
