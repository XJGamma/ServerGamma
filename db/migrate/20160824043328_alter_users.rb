class AlterUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.index :name
      t.index :token
      t.remove :email
      t.string :avatar
      t.datetime :token_created_at, :token_expired_at
    end
  end
end
