class CreateWidgets < ActiveRecord::Migration[5.1]
  def change
    create_table :widgets do |t|
      t.string :name
      t.string :description
      t.string :kind
      t.integer :userid
      t.string :username
      t.boolean :owner

      t.timestamps
    end
  end
end
