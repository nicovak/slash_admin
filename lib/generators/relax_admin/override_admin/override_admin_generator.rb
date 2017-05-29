# frozen_string_literal: true
module RelaxAdmin
  module Generators
    class OverrideAdminGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def override_admin
        template 'admin.erb',
                 'app/models/relax_admin/admin.rb'
      end
    end
  end
end
