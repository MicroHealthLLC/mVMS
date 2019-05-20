class ChangeAvatartoBlob < ActiveRecord::Migration[5.2]
  def self.up
    change_column :visitors, :avatar, :blob
  end
 def self.down
    change_column :visitors, :avatar, :text
  end
end
