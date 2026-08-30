class CreateUserStatuses < ActiveRecord::Migration[8.1]
  def change
    create_table :user_statuses do |t|
      t.integer :experiment, default: 0, null: false
      t.integer :level, default: 1, null: false
      t.integer :login_streak, default: 0, null: false
      t.integer :longest_login_streak, default: 0, null: false
      t.integer :want_registration_streak, default: 0, null: false
      t.integer :longest_want_registration_streak, default: 0, null: false
      t.date :last_login_date, default: -> { "CURRENT_DATE" }, null: false
      t.date :last_registration_date
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
