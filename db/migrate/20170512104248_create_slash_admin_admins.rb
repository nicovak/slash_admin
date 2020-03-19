# frozen_string_literal: true

class CreateSlashAdminAdmins < ActiveRecord::Migration[5.0]
  def change
    create_table :slash_admin_admins do |t|
      ## Database authenticatable
      t.string :username, null: false, default: ""
      t.string :email, null: false, default: ""
      t.string :password_digest, null: false, default: ""
      t.string :avatar
      t.string :roles

      ## Recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      t.timestamps null: false
    end
  end
end
