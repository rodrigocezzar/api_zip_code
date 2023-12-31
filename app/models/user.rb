# frozen_string_literal: true

class User < ApplicationRecord
  include ActiveModel::SecurePassword
  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, on: :create },
                    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 8, if: -> { password.present? } }
end
