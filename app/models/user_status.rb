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
            comparison: { less_than_or_equal_to: -> { Date.current } }

  # nil許容の日付
  validates :last_action_date,
            :last_want_registration_date,
            :random_gacha_date,
            comparison: { less_than_or_equal_to: -> { Date.current } },
            allow_nil: true

  # 1日のガチャ回数制限
  RANDOM_GACHA_LIMIT = 10

  # # ユーザー登録による経験値UP関連(仮：LvUPに必要分+EXPする予定)
  # SIGNUP_EXP = 10

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

  # ユーザー登録時のステータス更新記録
  def record_signup!
    process_exp_events!([signup_exp_event])
  end

  # ログイン時のステータス更新記録
  def record_daily_login!
    return [] if last_login_date == Date.current
    process_daily_login!
  end

  # やりたいこと登録時のステータス更新記録
  def record_want_registration!
    return [] if last_want_registration_date == Date.current
    process_daily_want_registration!
  end

  # やりたいことガチャ制限まで実施した際のステータス更新記録
  def record_random_wants_limit!
    return [] if last_action_date == Date.current
    process_daily_action!
  end

  # 次Lvまでに必要なEXP
  def required_exp_for_next_level
    required_exp_for(level)
  end

  # 次のLvまでの残りEXP
  def exp_to_next_level
    total_exp_for_next_level(level) - experience
  end

  # 現在Lvになってから獲得したEXP
  def current_level_exp
    experience - total_exp_for_current_level(level)
  end

  private

  # 経験値UP・レベルUP共通処理
  def process_exp_events!(exp_events)
    events = []
    new_exp = experience
    new_lv = level

    exp_events.each do |event|
      new_exp += event[:exp]
      events << event

      while new_exp >= total_exp_for_next_level(new_lv)
        new_lv += 1
        events << { type: "lv_up", level: new_lv }
      end
    end

    update!(experience: new_exp, level: new_lv)
    events
  end

  def signup_exp_event
    { type: "exp_up", source: "signup", exp: total_exp_for_next_level(level) }
  end

  def process_daily_login!
    transaction do
      update_login_status!
      process_exp_events!(login_exp_events)
    end
  end

  def update_login_status!
    new_login_streak = last_login_date == Date.yesterday ? login_streak + 1 : 1
    update!(
      last_login_date: Date.current,
      login_count: login_count + 1,
      login_streak: new_login_streak,
      longest_login_streak: [ longest_login_streak, new_login_streak ].max
    )
  end

  def login_exp_events
    [ login_exp_event, login_count_exp_event, login_streak_exp_event ].compact
  end

  def login_exp_event
    { type: "exp_up", source: "daily_login", exp: DAILY_LOGIN_EXP }
  end

  def login_count_exp_event
    return unless login_count % LOGIN_COUNT_BONUS_INTERVAL == 0
    { type: "exp_up", source: "login_count", exp: LOGIN_COUNT_BONUS_EXP }
  end

  def login_streak_exp_event
    return unless login_streak % LOGIN_STREAK_BONUS_INTERVAL == 0
    { type: "exp_up", source: "login_streak", exp: LOGIN_STREAK_BONUS_EXP }
  end

  def process_daily_want_registration!
    transaction do
      update!(last_want_registration_date: Date.current)
      process_daily_action!
    end
  end

  def process_daily_action!
    return if last_action_date == Date.current
    transaction do
      update_action_status!
      process_exp_events!(action_exp_events)
    end
  end

  def update_action_status!
    new_action_streak = last_action_date == Date.yesterday ? action_streak + 1 : 1
    update!(
      last_action_date: Date.current,
      action_count: action_count + 1,
      action_streak: new_action_streak,
      longest_action_streak: [ longest_action_streak, new_action_streak ].max
    )
  end

  def action_exp_events
    [ action_exp_event, action_count_exp_event, action_streak_exp_event ].compact
  end

  def action_exp_event
    { type: "exp_up", source: "daily_action", exp: DAILY_ACTION_EXP }
  end

  def action_count_exp_event
    return unless action_count % ACTION_COUNT_BONUS_INTERVAL == 0
    { type: "exp_up", source: "action_count", exp: ACTION_COUNT_BONUS_EXP }
  end

  def action_streak_exp_event
    return unless action_streak % ACTION_STREAK_BONUS_INTERVAL == 0
    { type: "exp_up", source: "action_streak", exp: ACTION_STREAK_BONUS_EXP }
  end

  # 指定Lvから次Lvへ上がるために必要なEXP
  def required_exp_for(lv)
    case lv
    when 1..57
      (10 * 1.05**(lv - 1)).floor
    when 58..100
      100 + lv
    else
      200
    end
  end

  # 次Lvに到達するために必要な累計EXP
  def total_exp_for_next_level(current_lv)
    (1..current_lv).sum { |lv| required_exp_for(lv) }
  end

  # 現在Lvに到達した時点の累計EXP
  def total_exp_for_current_level(current_lv)
    (1...current_lv).sum { |lv| required_exp_for(lv) }
  end
end
