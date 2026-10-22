class GuestUser < ApplicationRecord
  has_secure_token :token

  has_one :user_status, as: :owner, dependent: :destroy
  has_many :wants, as: :owner, dependent: :destroy

  DIRECT_REGISTRATION_LIMIT = 3
  GACHA_USAGE_LIMIT = 3

  # 自由登録とガチャの両方のゲスト体験が終了したか
  def experience_finished?
    # いずれかの体験枠が残っていれば終了ではない
    return false unless direct_registration_limit_reached?
    return false if gacha_usage_available?

    status = user_status

    # ガチャ3回目の利用日が終了している
    gacha_day_finished = status.random_gacha_date != Date.current

    # 当日のやりたいこと登録が完了している
    today_want_registered = status.last_want_registration_date == Date.current

    gacha_day_finished || today_want_registered
  end

  def direct_registration_limit_reached?
    direct_registration_count >= DIRECT_REGISTRATION_LIMIT
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
