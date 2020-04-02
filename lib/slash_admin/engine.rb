module SlashAdmin
  class Engine < ::Rails::Engine
    isolate_namespace SlashAdmin

    initializer "slash_admin.assets.precompile" do |app|
      app.config.assets.precompile += %w[slash_admin/*]
    end

    # config.to_prepare do
    #   Rails.application.config.assets.precompile += %w[slash_admin/*]
    # end
  end
end
