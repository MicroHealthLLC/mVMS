class AddStateToUser < ActiveRecord::Migration[5.2]
  def self.up
    add_column :users, :state, :boolean, default: false
    User.where(nil).update_all({state: true})
  end

  def self.down
    remove_column :users, :state, :boolean, default: false
  end
end
