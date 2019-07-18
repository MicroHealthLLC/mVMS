class AddEmailToPerson < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :email, :string
  end
end
