class Visitor < ApplicationRecord
  has_many :visitor_visit_informations, :dependent => :destroy

  def personvisiting
    visitor_visit_informations.last.try(:person_visiting)
  end

  def last_visit
    visitor_visit_informations.last || VisitorVisitInformation.new
  end
end
