class CreateUserData < ActiveRecord::Migration
  def change
    create_table :user_data do |t|
      t.references :user, index: true
      t.string :book_name
      t.binary :content, :limit => 10.megabyte
      
      t.timestamps null: false, index: true
    end
  end
end
