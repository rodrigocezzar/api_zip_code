# frozen_string_literal: true

class User < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, on: :create },
                    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 8, if: -> { password_digest.present? } }
end
