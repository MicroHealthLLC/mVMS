class AddLuxandCloudPersonIdToVisitor < ActiveRecord::Migration[5.2]
  def change
    add_column :visitors, :luxand_cloud_person_id, :integer, default: nil
  end
end
