class UserStatus < ApplicationRecord
  belongs_to :user
  validates :level, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :experimence, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :login_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :login_streak, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :longest_login_streak, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :action_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :action_streak, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :longest_action_streak, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :last_login_date, presence: true, comparison: { less_than_or_equal_to: Date.current }
  validates :last_action_date, comparison: { less_than_or_equal_to: Date.current }, allow_nil: true
  validates :last_want_registration_date, comparison: { less_than_or_equal_to: Date.current }, allow_nil: true
  validates :random_gacha_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :random_gacha_date, comparison: { less_than_or_equal_to: Date.current }, allow_nil: true

  RANDOM_GACHA_LIMIT = 10
  DAILY_LOGIN_EXP = 10
  LOGIN_COUNT_BONUS_INTERVAL = 10
  LOGIN_COUNT_BONUS_EXP = 10
  LOGIN_STREAK_BONUS_INTERVAL = 10
  LOGIN_STREAK_BONUS_EXP = 10

  def random_gacha_available?
    random_gacha_date != Date.current || random_gacha_count < RANDOM_GACHA_LIMIT
  end

  def record_daily_login!
    return if last_login_date == Date.current

    transaction do
      login_status = update_login_status!
      grant_login_exp!(login_status)
    end
  end

  private

  def update_login_status!
    new_login_count = login_count + 1
    new_login_streak = last_login_date == Date.yesterday ? login_streak + 1 : 1

    update!(
      last_login_date: Date.current,
      login_count: new_login_count,
      login_streak: new_login_streak,
      longest_login_streak: [longest_login_streak, new_login_streak].max
    )

    {
      login_count: new_login_count,
      login_streak: new_login_streak
    }
  end

  def grant_login_exp!(login_status)
    rewards = [
      daily_login_exp_reward,
      login_count_exp_reward(login_status[:login_count]),
      login_streak_exp_reward(login_status[:login_streak])
    ].compact
    update!(experimence: experimence + rewards.sum { |reward| reward[:exp] })
    rewards
  end

  def daily_login_exp_reward
    {
      type: :daily_login,
      exp: DAILY_LOGIN_EXP,
      message: "ログイン +#{DAILY_LOGIN_EXP}EXP"
    }
  end

  def login_count_exp_reward(login_count)
    return unless login_count % LOGIN_COUNT_BONUS_INTERVAL == 0
    {
      type: :login_count,
      exp: LOGIN_COUNT_BONUS_EXP,
      message: "累計ログイン#{login_count}日 +#{LOGIN_COUNT_BONUS_EXP}EXP"
    }
  end

  def login_streak_exp_reward(login_streak)
    return unless login_streak % LOGIN_STREAK_BONUS_INTERVAL == 0
    {
      type: :login_streak,
      exp: LOGIN_STREAK_BONUS_EXP,
      message: "#{login_streak}日連続ログイン +#{LOGIN_STREAK_BONUS_EXP}EXP"
    }
  end
end
