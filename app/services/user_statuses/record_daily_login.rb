module UserStatuses
  class RecordDailyLogin
    def initialize(user_status:)
      @user_status = user_status
    end

    def call
      @user_status.with_lock do
        today = Date.current

        if @user_status.last_login_date == today
          []
        else
          new_streak = @user_status.last_login_date == today - 1 ? @user_status.login_streak + 1 : 1

          @user_status.update!(
            last_login_date: today,
            login_count: @user_status.login_count + 1,
            login_streak: new_streak,
            longest_login_streak: [
              @user_status.longest_login_streak,
              new_streak
            ].max
          )

          Experience::Grant.new(
            user_status: @user_status,
            exp_events: login_exp_events
          ).call
        end
      end
    end

    private

    def login_exp_events
      events = [
        {
          type: "exp_up",
          source: "daily_login",
          exp: UserStatus::DAILY_LOGIN_EXP
        }
      ]

      if (@user_status.login_count % UserStatus::LOGIN_COUNT_BONUS_INTERVAL).zero?
        events << {
          type: "exp_up",
          source: "login_count",
          exp: UserStatus::LOGIN_COUNT_BONUS_EXP
        }
      end

      if (@user_status.login_streak % UserStatus::LOGIN_STREAK_BONUS_INTERVAL).zero?
        events << {
          type: "exp_up",
          source: "login_streak",
          exp: UserStatus::LOGIN_STREAK_BONUS_EXP
        }
      end

      events
    end
  end
end
