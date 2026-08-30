class User < ApplicationRecord
  has_many :wants, dependent: :destroy
  has_many :user_statuses, dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  # nameの空白を削除する or 空白文字等の場合にnilを返す
  normalizes :name, with: ->(name) { name.strip.presence }
  validates :name, length: { maximum: 40 }, allow_nil: true
end
