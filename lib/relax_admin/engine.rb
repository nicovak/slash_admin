module RelaxAdmin
  class Engine < ::Rails::Engine
    isolate_namespace RelaxAdmin
    config.to_prepare do
      Rails.application.config.assets.precompile += %w( relax_admin/* )
    end
  end
end
