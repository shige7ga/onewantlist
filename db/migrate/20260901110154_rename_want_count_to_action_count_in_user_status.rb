class RenameWantCountToActionCountInUserStatus < ActiveRecord::Migration[8.1]
  def change
    rename_column :user_statuses, :want_registration_count, :action_count
    rename_column :user_statuses, :want_registration_streak, :action_streak
    rename_column :user_statuses, :longest_want_registration_streak, :longest_action_streak
    rename_column :user_statuses, :last_registration_date, :last_action_date

    add_column :user_statuses, :random_gacha_count, :integer, default: 0, null: false
    add_column :user_statuses, :random_gacha_date, :date
  end
end
