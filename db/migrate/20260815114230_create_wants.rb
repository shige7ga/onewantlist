class CreateWants < ActiveRecord::Migration[8.1]
  def change
    create_table :wants do |t|
      t.references :user, null: false, foreign_key: true
      t.string :content, null: false
      t.integer :status, null: false, default: 0
      t.datetime :due_date

      t.timestamps
    end
  end
end
