class ChangeColumnInUserStatus < ActiveRecord::Migration[8.1]
  def change
    change_column_null :user_statuses, :last_login_date, true
    change_column_null :user_statuses, :login_count, true
    change_column_null :user_statuses, :login_streak, true
    change_column_null :user_statuses, :longest_login_streak, true

    change_column_default :user_statuses,
                          :last_login_date,
                          from: -> { "CURRENT_DATE" },
                          to: nil

    change_column_default :user_statuses,
                          :login_count,
                          from: 1,
                          to: nil

    change_column_default :user_statuses,
                          :login_streak,
                          from: 1,
                          to: nil

    change_column_default :user_statuses,
                          :longest_login_streak,
                          from: 1,
                          to: nil
  end
end
