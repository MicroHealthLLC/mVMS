class AddNameToVisitorVisitiTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :visitor_visit_informations, :name, :string
    add_column :visitor_visit_informations, :phone, :string
    add_column :visitor_visit_informations, :company, :string
    add_column :visitor_visit_informations, :updated, :boolean, default: false


    Visitor.all.each do |visitor|
      visitor.visitor_visit_informations.update_all({name: visitor.name, company: visitor.company, phone: visitor.phone})
      visitor.visitor_visit_informations.first.update({updated: true})
    end
  end
end
