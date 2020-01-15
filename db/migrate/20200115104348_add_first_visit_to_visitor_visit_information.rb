class AddFirstVisitToVisitorVisitInformation < ActiveRecord::Migration[5.2]
  def change
    add_column :visitor_visit_informations, :first_visit, :boolean, default: true
    exec = VisitorVisitInformation.group(:visitor_id).count
    v = exec.select{|_, v| v > 1}.map(&:first)
    VisitorVisitInformation.where(visitor_id: v).each do |vvi|
      if VisitorVisitInformation.where(visitor_id:  vvi.visitor_id).where('id < ?', vvi.id).present?
        vvi.first_visit = false
        vvi.save
      end
    end
  end
end
