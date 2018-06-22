class Visitor < ApplicationRecord
  has_many :visitor_visit_informations, :dependent => :destroy

  def personvisiting
    visitor_visit_informations.last.try(:person_visiting)
  end
end
