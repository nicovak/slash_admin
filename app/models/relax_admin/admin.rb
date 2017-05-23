# frozen_string_literal: true
# == Schema Information
#
# Table name: admins
#
#  id                     :integer          not null, primary key
#  username               :string           default(""), not null
#  email                  :string           default(""), not null
#  password_digest        :string           default(""), not null
#  avatar                 :string
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_admins_on_email                 (email) UNIQUE
#  index_admins_on_reset_password_token  (reset_password_token) UNIQUE
#  index_admins_on_username              (username) UNIQUE
#
module RelaxAdmin
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

    def login=(login)
      @login = login
    end

    def login
      @login || self.username || self.email
    end

    def identicon
      RubyIdenticon.create_base64(email, grid_size: 5, border_size: 150, square_size: 50, background_color: 0xf0f0f0ff)
    end
  end
end
