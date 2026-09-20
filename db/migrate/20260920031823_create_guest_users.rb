class CreateGuestUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :guest_users do |t|
      t.string :token, null: false

      t.timestamps
    end

    add_index :guest_users, :token, unique: true
  end
end
