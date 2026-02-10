class CreateGroups < ActiveRecord::Migration[7.2]
  def change
    create_table :groups do |t|
      t.string :name,         null: false
      t.string :invite_token, null: false, limit: 24
      t.boolean :is_guest,    null: false, default: false
      t.datetime :expires_at

      t.timestamps
    end

    add_index :groups, :invite_token, unique: true
    add_index :groups, [:is_guest, :expires_at]
  end
end
