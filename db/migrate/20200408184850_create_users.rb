class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :firstname
      t.string :lastname
      t.string :password
      t.string :password_confirmed
      t.string :email
      t.string :imageurl

      t.timestamps
    end
  end
end
