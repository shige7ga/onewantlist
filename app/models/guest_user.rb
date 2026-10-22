class GuestUser < ApplicationRecord
  has_secure_token :token

  has_one :user_status, as: :owner, dependent: :destroy
  has_many :wants, as: :owner, dependent: :destroy

  DIRECT_REGISTRATION_LIMIT = 3
  GACHA_USAGE_LIMIT = 3

  # 自由登録とガチャの両方のゲスト体験が終了したか
  def experience_finished?
    !direct_registration_available? && gacha_usage_limited?
  end

  def direct_registration_available?
    direct_registration_count < DIRECT_REGISTRATION_LIMIT
  end

  # ガチャ体験が利用制限に達しているか
  def gacha_usage_limited?
    return false if gacha_usage_available?

    user_status.random_gacha_date != Date.current || user_status.last_want_registration_date == Date.current
  end

  def gacha_usage_available?
    gacha_usage_count < GACHA_USAGE_LIMIT
  end

  def record_direct_registration!
    increment!(:direct_registration_count)
  end

  def record_gacha_usage!
    increment!(:gacha_usage_count)
  end

  def remaining_direct_registrations
    [ DIRECT_REGISTRATION_LIMIT - direct_registration_count, 0 ].max
  end

  def remaining_gacha_usages
    [ GACHA_USAGE_LIMIT - gacha_usage_count, 0 ].max
  end

  def name
    "ゲストユーザー"
  end
end
