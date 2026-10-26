class CreateMemos < ActiveRecord::Migration[8.1]
  def change
    create_table :memos do |t|
      t.text :content, null: true

      t.timestamps
    end
  end
end
