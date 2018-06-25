class Visitor < ApplicationRecord
  has_many :visitor_visit_informations, :dependent => :destroy

  validates_presence_of :name, :email
  validates_uniqueness_of :email

  def personvisiting
    visitor_visit_informations.last.try(:person_visiting)
  end

  def last_visit
    visitor_visit_informations.last || VisitorVisitInformation.new
  end

  def status
    if email.nil? || phone.nil? || company.nil? || us_citizen.nil?
      return '02222'
    end
    nil
  end

end
