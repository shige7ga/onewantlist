class AddLastWantRegistrationDateColumnToUserStatus < ActiveRecord::Migration[8.1]
  def change
    add_column :user_statuses, :last_want_registration_date, :date
  end
end
