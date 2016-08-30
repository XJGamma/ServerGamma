class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.text   :password_hash
      t.text   :password_salt
      t.string :token

      t.timestamps null: false
    end
  end
end
