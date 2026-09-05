class User < ApplicationRecord
  has_many :wants, dependent: :destroy
  has_one :user_status, dependent: :destroy
  after_create :create_default_user_status

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # nameの空白を削除する or 空白文字等の場合にnilを返す
  normalizes :name, with: ->(name) { name.strip.presence }
  validates :name, length: { maximum: 40 }, allow_nil: true

  private

  # ユーザー登録時に、デフォルトのステータスを作成し紐づける。
  def create_default_user_status
    create_user_status!(last_login_date: Date.current)
  end
end
