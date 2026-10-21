module UserStatuses
  class RecordDailyAction
    def initialize(user_status:, want_registration: false)
      @user_status = user_status
      @want_registration = want_registration
    end

    def call
      @user_status.with_lock do
        today = Date.current

        if @want_registration &&
           @user_status.last_want_registration_date == today
          []
        else
          record_action!(today)
        end
      end
    end

    private

    def record_action!(today)
      # 本日のアクションEXPが付与済みの場合
      if @user_status.last_action_date == today
        if @want_registration
          @user_status.update!(
            last_want_registration_date: today
          )
        end

        return []
      end

      # 連続日数の計算
      new_streak = @user_status.last_action_date == today - 1 ? @user_status.action_streak + 1 : 1

      # 更新する属性
      attributes = {
        last_action_date: today,
        action_count: @user_status.action_count + 1,
        action_streak: new_streak,
        longest_action_streak: [
          @user_status.longest_action_streak,
          new_streak
        ].max
      }

      # やりたいこと登録時のみ登録日を更新
      if @want_registration
        attributes[:last_want_registration_date] = today
      end

      @user_status.update!(attributes)

      Experience::Grant.new(
        user_status: @user_status,
        exp_events: action_exp_events
      ).call
    end

    def action_exp_events
      events = [
        {
          type: "exp_up",
          source: "daily_action",
          exp: UserStatus::DAILY_ACTION_EXP
        }
      ]

      if (@user_status.action_count % UserStatus::ACTION_COUNT_BONUS_INTERVAL).zero?
        events << {
          type: "exp_up",
          source: "action_count",
          exp: UserStatus::ACTION_COUNT_BONUS_EXP
        }
      end

      if (@user_status.action_streak % UserStatus::ACTION_STREAK_BONUS_INTERVAL).zero?
        events << {
          type: "exp_up",
          source: "action_streak",
          exp: UserStatus::ACTION_STREAK_BONUS_EXP
        }
      end

      events
    end
  end
end
