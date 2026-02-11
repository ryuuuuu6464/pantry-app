class CreateInventories < ActiveRecord::Migration[7.2]
  def change
    create_table :inventories do |t|
      t.references :group, null: false, foreign_key: { on_delete: :cascade }
      t.references :item,  null: false, foreign_key: { on_delete: :cascade }
      t.integer :quantity, null: false, default:0

      t.timestamps
    end

    add_index :inventories, [:group_id, :item_id], unique: true
  end
end
