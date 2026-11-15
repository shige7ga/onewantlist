class StatusesController < ApplicationController
  def show
    @owner = current_owner
    @user_status = @owner.user_status

    wants = @owner.wants

    # やりたいことの件数
    @want_counts = {
      total: wants.count,
      completed: wants.completed.count,
      not_started: wants.not_started.count,
      in_progress: wants.in_progress.count
    }

    # 今月の登録数
    @monthly_registration_count = wants.where(created_at: Time.current.all_month).count
  end
end
