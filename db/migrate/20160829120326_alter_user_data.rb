class AlterUserData < ActiveRecord::Migration
  def change
    change_table :user_data do |t|
      t.remove :book_name
      t.remove :content
      t.text :content, :limit => 10.megabyte
    end
  end
end
