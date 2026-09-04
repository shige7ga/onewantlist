class RenameWantCountToActionCountInUserStatus < ActiveRecord::Migration[8.1]
  def up
    # 過去のマイグレーションを後から変更したことで、本番DBに存在しないカラムを補完する
    unless column_exists?(:user_statuses, :login_count)
      add_column :user_statuses,
                 :login_count,
                 :integer,
                 default: 1,
                 null: false
    end

    # 本番DBでは experiment、ローカルDBでは experimence の可能性がある
    if column_exists?(:user_statuses, :experiment) &&
       !column_exists?(:user_statuses, :experimence)
      rename_column :user_statuses, :experiment, :experimence
    end

    rename_or_add_action_column
    rename_action_streak_columns
    rename_last_action_date_column
    add_gacha_columns

    # 既存データを現在のバリデーションに合わせる
    execute <<~SQL.squish
      UPDATE user_statuses
      SET login_streak = 1
      WHERE login_streak < 1
    SQL

    execute <<~SQL.squish
      UPDATE user_statuses
      SET longest_login_streak = 1
      WHERE longest_login_streak < 1
    SQL

    change_column_default :user_statuses,
                          :login_streak,
                          from: 0,
                          to: 1

    change_column_default :user_statuses,
                          :longest_login_streak,
                          from: 0,
                          to: 1
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def rename_or_add_action_column
    if column_exists?(:user_statuses, :want_registration_count)
      rename_column :user_statuses,
                    :want_registration_count,
                    :action_count
    elsif !column_exists?(:user_statuses, :action_count)
      add_column :user_statuses,
                 :action_count,
                 :integer,
                 default: 0,
                 null: false
    end
  end

  def rename_action_streak_columns
    if column_exists?(:user_statuses, :want_registration_streak) &&
       !column_exists?(:user_statuses, :action_streak)
      rename_column :user_statuses,
                    :want_registration_streak,
                    :action_streak
    end

    if column_exists?(:user_statuses, :longest_want_registration_streak) &&
       !column_exists?(:user_statuses, :longest_action_streak)
      rename_column :user_statuses,
                    :longest_want_registration_streak,
                    :longest_action_streak
    end
  end

  def rename_last_action_date_column
    if column_exists?(:user_statuses, :last_registration_date) &&
       !column_exists?(:user_statuses, :last_action_date)
      rename_column :user_statuses,
                    :last_registration_date,
                    :last_action_date
    end
  end

  def add_gacha_columns
    unless column_exists?(:user_statuses, :random_gacha_count)
      add_column :user_statuses,
                 :random_gacha_count,
                 :integer,
                 default: 0,
                 null: false
    end

    unless column_exists?(:user_statuses, :random_gacha_date)
      add_column :user_statuses, :random_gacha_date, :date
    end
  end
end
