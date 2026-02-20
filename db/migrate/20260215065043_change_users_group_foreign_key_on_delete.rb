class ChangeUsersGroupForeignKeyOnDelete < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key :users, :groups
    add_foreign_key :users, :groups, on_delete: :nullify
  end
end
