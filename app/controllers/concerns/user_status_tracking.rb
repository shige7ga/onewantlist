module UserStatusTracking
  extend ActiveSupport::Concern

  private

  def record_daily_login
    add_status_events(
      current_user.user_status.record_daily_login!
    )
  end

  def reset_expired_action_streak
    current_owner.user_status.reset_action_streak_if_expired!
  end
end
