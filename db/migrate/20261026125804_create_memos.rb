class CreateMemos < ActiveRecord::Migration[8.1]
  def change
    create_table :memos do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      t.text :content, null: true

      t.timestamps
    end
  end
end
