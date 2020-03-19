# frozen_string_literal: true

require "pagy/extras/bootstrap"
require "pagy/extras/i18n"
require "pagy/extras/array"
require "pagy/extras/searchkick"

Rails.application.config.assets.paths << Pagy.root.join("javascripts")
