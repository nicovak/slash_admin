# frozen_string_literal: true

module SlashAdmin
  class Admin < ApplicationRecord
    include CanCan::Ability

    has_secure_password

    attr_accessor :login

    EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
    USERNAME_REGEX = /^[a-zA-Z0-9_\.]*$/
    validates :username, presence: true, uniqueness: true, length: {in: 3..20}
    validates :email, presence: true, uniqueness: true
    validates_length_of :password, in: 6..20, on: :create
    validates_format_of :email, with: EMAIL_REGEX, multiline: true
    validates_format_of :username, with: USERNAME_REGEX, multiline: true

    before_create :handle_default_role

    serialize :roles, JSON

    def has_role?(role)
      if roles.blank?
        false
      else
        roles.include?(role)
      end
    end

    def handle_default_role
      self.roles = "superadmin" unless roles.present?
    end

    attr_writer :login

    def login
      @login || username || email
    end

    def identicon
      RubyIdenticon.create_base64(email, grid_size: 5, border_size: 150, square_size: 50, background_color: 0xf0f0f0ff)
    end
  end
end
