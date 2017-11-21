# frozen_string_literal: true
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'relax_admin/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'relax_admin'
  s.version     = RelaxAdmin::VERSION
  s.required_ruby_version = '>= 2.4.0'
  s.authors     = ['KOVACS Nicolas']
  s.email       = ['pro.nicovak@gmail.com']
  s.homepage    = 'http://relaxadmin.github.io'
  s.summary     = 'A modern and overridable admin gem, just the rails way.'
  s.description = 'A modern and overridable admin gem, just the rails way.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib,vendor}/**/*', 'README.md', 'LICENSE.md']

  s.add_dependency 'rails', '~> 5.0'
  s.add_dependency 'http_accept_language'
  s.add_dependency 'kaminari'
  s.add_dependency 'cancancan'
  s.add_dependency 'groupdate'
  s.add_dependency 'ruby_identicon'
  s.add_dependency 'bcrypt'
  s.add_dependency 'chartkick'
  s.add_dependency 'chart-js-rails'
  s.add_dependency 'highcharts-rails'
  s.add_dependency 'selectize-rails'
  s.add_dependency 'font-awesome-rails'
  s.add_dependency 'bootstrap', '~> 4.0.0.beta'
  s.add_dependency 'cocoon'
  s.add_dependency 'datetime_picker_rails'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'bootstrap-datepicker-rails'
  s.add_dependency 'jquery-minicolors-rails'
  s.add_dependency 'momentjs-rails'
  s.add_dependency 'sass-rails'
  s.add_dependency 'tether-rails'
  s.add_dependency 'sweetalert-rails'

  s.add_development_dependency 'sqlite3'
end
