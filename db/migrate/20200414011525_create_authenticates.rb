class CreateAuthenticates < ActiveRecord::Migration[5.1]
  def change
    create_table :authenticates do |t|
      t.string :email
      t.string :password

      t.timestamps
    end
  end
end
