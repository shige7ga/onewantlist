class GuestUser < ApplicationRecord
  has_secure_token :token

  has_one :user_status, as: :owner, dependent: :destroy
  has_many :wants, as: :owner, dependent: :destroy
end
