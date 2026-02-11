class CreateItems < ActiveRecord::Migration[7.2]
  def change
    create_table :items do |t|
      t.references :group,    null: false, foreign_key: { on_delete: :cascade }
      t.references :category, null: false, foreign_key: { on_delete: :cascade }
      t.string :name,         null: false

      t.timestamps
    end

    add_index :items, [:group_id, :name], unique: true
  end
end
