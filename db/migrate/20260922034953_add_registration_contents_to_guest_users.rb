class AddRegistrationContentsToGuestUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :guest_users, :direct_registration_count, :integer, default: 0, null: false
    add_column :guest_users, :gacha_usage_count, :integer, default: 0, null:  false
  end
end
