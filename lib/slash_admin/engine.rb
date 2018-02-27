module SlashAdmin
  class Engine < ::Rails::Engine
    isolate_namespace SlashAdmin
    config.to_prepare do
      Rails.application.config.assets.precompile += %w( slash_admin/* )
    end
  end
end
