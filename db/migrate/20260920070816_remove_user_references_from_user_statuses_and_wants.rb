class RemoveUserReferencesFromUserStatusesAndWants < ActiveRecord::Migration[8.1]
  def change
    remove_reference :user_statuses, :user, foreign_key: true
    remove_reference :wants, :user, foreign_key: true
  end
end
