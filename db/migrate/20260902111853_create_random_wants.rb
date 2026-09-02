class CreateRandomWants < ActiveRecord::Migration[8.1]
  def change
    create_table :random_wants do |t|
      t.string :content, null: false

      t.timestamps
    end
  end
end
