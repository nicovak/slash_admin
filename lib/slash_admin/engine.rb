require "pagy"
require "pagy/extras/bootstrap"
require "pagy/extras/i18n"
require "pagy/extras/array"

module SlashAdmin
  class Engine < ::Rails::Engine
    isolate_namespace SlashAdmin

    initializer "slash_admin.assets.precompile" do |app|
      app.config.assets.precompile += %w(slash_admin slash_admin_manifest.js)
      app.config.assets.paths << Pagy.root.join("javascripts")
    end
  end
end
