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

    # 表示対象の月
    @calendar_date = calendar_date

    # 表示月の開始・終了日時
    month_start = @calendar_date.beginning_of_month.in_time_zone
    month_end = month_start.next_month

    # 表示月の登録日時を取得
    registered_at = @owner.wants
                          .where(created_at: month_start...month_end)
                          .pluck(:created_at)

    # 登録した日付の一覧
    @registered_dates = registered_at.map do |created_at|
      created_at.in_time_zone.to_date
    end.uniq

    # 表示月の登録件数
    @monthly_registration_count = registered_at.size
  end

  private

  def calendar_date
    Date.iso8601(params[:start_date])
  rescue ArgumentError, TypeError
    Date.current
  end
end
