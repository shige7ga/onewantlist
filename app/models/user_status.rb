class UserStatus < ApplicationRecord
  belongs_to :owner, polymorphic: true

  # バリデーション
  # 1以上
  validates :level, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  # 0以上
  validates :experience,
            :action_count,
            :action_streak,
            :longest_action_streak,
            :random_gacha_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # nil許容の日付
  validates :last_action_date,
            :last_want_registration_date,
            :random_gacha_date,
            comparison: { less_than_or_equal_to: -> { Date.current } },
            allow_nil: true

  with_options if: :user_owner? do
    # 必須とする日付
    validates :last_login_date,
              presence: true,
              comparison: { less_than_or_equal_to: -> { Date.current } }

    # 1以上
    validates :login_count,
              :login_streak,
              :longest_login_streak,
              numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  end

  # 1日のガチャ回数制限
  RANDOM_GACHA_LIMIT = 10

  # 初回アクセスによる経験値UP
  FIRST_VISIT_EXP = 10

  # ログインによる経験値UP関連
  DAILY_LOGIN_EXP = 10
  LOGIN_COUNT_BONUS_INTERVAL = 10
  LOGIN_COUNT_BONUS_EXP = 10
  LOGIN_STREAK_BONUS_INTERVAL = 10
  LOGIN_STREAK_BONUS_EXP = 10

  # アクションによる経験値UP関連
  DAILY_ACTION_EXP = 10
  ACTION_COUNT_BONUS_INTERVAL = 10
  ACTION_COUNT_BONUS_EXP = 10
  ACTION_STREAK_BONUS_INTERVAL = 10
  ACTION_STREAK_BONUS_EXP = 10

  def random_gacha_available?
    random_gacha_date != Date.current || random_gacha_count < RANDOM_GACHA_LIMIT
  end

  def reset_action_streak_if_expired!
    return if last_action_date.nil?
    return if last_action_date >= Date.yesterday
    return if action_streak.zero?

    update!(action_streak: 0)
  end

  # ユーザー登録時のステータス更新記録
  def record_signup!
    process_exp_events!([ signup_exp_event ])
  end

  # 初回アクセス時のステータス更新
  def record_first_visit!
    process_exp_events!([ first_visit_exp_event ])
  end

  # ログイン時のステータス更新
  def record_daily_login!
    UserStatuses::RecordDailyLogin.new(
      user_status: self
    ).call
  end

  # やりたいこと登録時のステータス更新
  def record_want_registration!
    UserStatuses::RecordDailyAction.new(
      user_status: self,
      want_registration: true
    ).call
  end

  # ガチャ上限達成時のステータス更新
  def record_random_wants_limit!
    UserStatuses::RecordDailyAction.new(
      user_status: self,
    ).call
  end

  # 次Lvまでに必要なEXP
  def required_exp_for_next_level
    Experience::LevelCalculator.required_exp_for(level)
  end

  # 次のLvまでの残りEXP
  def exp_to_next_level
    Experience::LevelCalculator.total_exp_for_next_level(level) - experience
  end

  # 現在Lvになってから獲得したEXP
  def current_level_exp
    experience - Experience::LevelCalculator.total_exp_for_current_level(level)
  end

  # 経験値ゲージのアニメーション用データ
  def exp_gauge_animation(events)
    Experience::GaugePresenter.new(
      level: level,
      experience: experience,
      events: events
    ).call
  end

  private

  def user_owner?
    owner_type == "User"
  end

  # 経験値UP・レベルUP共通処理
  def process_exp_events!(exp_events)
    Experience::Grant.new(
      user_status: self,
      exp_events: exp_events
    ).call
  end

  def signup_exp_event
    { type: "exp_up", source: "signup", exp: required_exp_for_next_level }
  end

  def first_visit_exp_event
    { type: "exp_up", source: "first_visit", exp: FIRST_VISIT_EXP }
  end
end
