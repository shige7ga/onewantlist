class ConvertUserAssociationsToPolymorphicOwner < ActiveRecord::Migration[8.1]
  def up
    add_reference :user_statuses,
                  :owner,
                  polymorphic: true,
                  index: { unique: true }

    add_reference :wants,
                  :owner,
                  polymorphic: true,
                  index: true

    execute <<~SQL
      UPDATE user_statuses
      SET owner_type = 'User',
          owner_id = user_id
      WHERE user_id IS NOT NULL
    SQL

    execute <<~SQL
      UPDATE wants
      SET owner_type = 'User',
          owner_id = user_id
      WHERE user_id IS NOT NULL
    SQL

    change_column_null :user_statuses, :owner_type, false
    change_column_null :user_statuses, :owner_id, false

    change_column_null :wants, :owner_type, false
    change_column_null :wants, :owner_id, false
  end

  def down
    remove_reference :wants,
                     :owner,
                     polymorphic: true

    remove_reference :user_statuses,
                     :owner,
                     polymorphic: true
  end
end
