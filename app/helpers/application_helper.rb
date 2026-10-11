module ApplicationHelper

  # EXP付与メッセージ用
  def exp_gain_messages(events)
    labels = {
      "signup" => "ユーザー登録",
      "first_visit" => "初回アクセス",
      "daily_login" => "ログイン",
      "login_count" => "累計ログイン回数達成",
      "login_streak" => "連続ログイン達成",
      "daily_action" => "今日のアクション達成",
      "action_count" => "累計アクション回数達成",
      "action_streak" => "連続アクション達成"
    }

    events.filter_map do |event|
      event = event.with_indifferent_access

      next unless event[:type] == "exp_up"

      label = labels.fetch(event[:source], "アクション")

      "#{label}により＋#{event[:exp]}EXP"
    end
  end
end
