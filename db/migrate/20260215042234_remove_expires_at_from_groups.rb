class RemoveExpiresAtFromGroups < ActiveRecord::Migration[7.2]
  def change
    remove_index :groups, name: "index_groups_on_is_guest_and_expires_at", if_exists: true
    remove_column :groups, :expires_at, :datetime
  end
end
