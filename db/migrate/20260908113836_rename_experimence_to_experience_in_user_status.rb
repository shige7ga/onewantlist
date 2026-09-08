class RenameExperimenceToExperienceInUserStatus < ActiveRecord::Migration[8.1]
  def change
    rename_column :user_statuses, :experimence, :experience
  end
end
