class ChangeUserAvatar < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.remove :avatar
      t.text :avatar, :limit => 10.megabyte
    end
  end
end
