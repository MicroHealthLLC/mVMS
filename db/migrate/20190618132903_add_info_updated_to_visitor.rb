class AddInfoUpdatedToVisitor < ActiveRecord::Migration[5.2]
  def change
    add_column :visitors, :info_updated, :boolean, default: false
    add_column :visitor_visit_informations, :info_updated, :boolean, default: false
  end
end
