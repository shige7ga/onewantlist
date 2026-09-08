class UserStatus < ApplicationRecord
  belongs_to :user

  # バリデーション
  # 1以上
  validates :level,
            :login_count,
            :login_streak,
            :longest_login_streak,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  # 0以上
  validates :experience,
            :action_count,
            :action_streak,
            :longest_action_streak,
            :random_gacha_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # 必須とする日付
  validates :last_login_date,
            presence: true,
            comparison: { less_than_or_equal_to: ->{ Date.current } }

  # nil許容の日付
  validates :last_action_date,
            :last_want_registration_date,
            :random_gacha_date,
            comparison: { less_than_or_equal_to: Date.current },
            allow_nil: true

  # 1日のガチャ回数制限
  RANDOM_GACHA_LIMIT = 10

  # ログインによる経験値
  DAILY_LOGIN_EXP = 10
  LOGIN_COUNT_BONUS_INTERVAL = 10
  LOGIN_COUNT_BONUS_EXP = 10
  LOGIN_STREAK_BONUS_INTERVAL = 10
  LOGIN_STREAK_BONUS_EXP = 10

  # アクションによる経験値
  DAILY_ACTION_EXP = 10
  ACTION_COUNT_BONUS_INTERVAL = 10
  ACTION_COUNT_BONUS_EXP = 10
  ACTION_STREAK_BONUS_INTERVAL = 10
  ACTION_STREAK_BONUS_EXP = 10

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

  def record_want_registration!
    return if last_want_registration_date == Date.current

    transaction do
      update!(last_want_registration_date: Date.current)
      update_action_status_and_exp!
    end
  end

  def record_random_wants_limit!
    update_action_status_and_exp!
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
    update!(experience: experience + rewards.sum { |reward| reward[:exp] })
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

  def update_action_status_and_exp!
    return if last_action_date == Date.current

    transaction do
      action_status = update_action_status!
      grant_action_exp!(action_status)
    end
  end

  def update_action_status!
    new_action_count = action_count + 1
    new_action_streak = last_action_date == Date.yesterday ? action_streak + 1 : 1

    update!(
      last_action_date: Date.current,
      action_count: new_action_count,
      action_streak: new_action_streak,
      longest_action_streak: [longest_action_streak, new_action_streak].max
    )

    {
      action_count: new_action_count,
      action_streak: new_action_streak
    }
  end

  def grant_action_exp!(action_status)
    rewards = [
      daily_action_exp_reward,
      action_count_exp_reward(action_status[:action_count]),
      action_streak_exp_reward(action_status[:action_streak])
    ].compact
    update!(experience: experience + rewards.sum { |reward| reward[:exp] })
    rewards
  end

  def daily_action_exp_reward
    {
      type: :daily_action,
      exp: DAILY_ACTION_EXP,
      message: "アクション +#{DAILY_ACTION_EXP}EXP"
    }
  end

  def action_count_exp_reward(action_count)
    return unless action_count % ACTION_COUNT_BONUS_INTERVAL == 0
    {
      type: :action_count,
      exp: ACTION_COUNT_BONUS_EXP,
      message: "累計アクション#{action_count}日 +#{ACTION_COUNT_BONUS_EXP}EXP"
    }
  end

  def action_streak_exp_reward(action_streak)
    return unless action_streak % ACTION_STREAK_BONUS_INTERVAL == 0
    {
      type: :action_streak,
      exp: ACTION_STREAK_BONUS_EXP,
      message: "#{action_streak}日連続アクション +#{ACTION_STREAK_BONUS_EXP}EXP"
    }
  end
end
