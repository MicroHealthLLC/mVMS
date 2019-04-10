# == Schema Information
#
# Table name: visitors
#
#  id               :bigint(8)        not null, primary key
#  name             :string(255)
#  company          :string(255)
#  phone            :string(255)
#  email            :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  us_citizen       :string(255)
#  avatar           :text(65535)
#  person_signature :text(65535)
#

class Visitor < ApplicationRecord
  has_many :visitor_visit_informations, :dependent => :destroy

  validates_presence_of :name, :email
  validates_uniqueness_of :email

  def personvisiting
    visitor_visit_informations.last.try(:person_visiting)
  end

  def has_visit_missed?
    visitor_visit_informations.where(sign_out_date: nil).present?
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

  def last_missed_visit
    @last_missed_visit||= visitor_visit_informations.where(sign_out_date: nil).last
  end

  def to_json
    last_visit = visitor_visit_informations.last
    {
        display_name: self.name,
        display_company: self.company,
        display_phone: self.phone,
        avatar: self.avatar,
        display_email: self.email,

        display_reason: last_visit&.visit_reason,
        display_personvisit: last_visit&.person.try(:name),
        display_citizen: self.us_citizen?,

        display_classified: last_visit&.classified?,
        display_date_in: last_visit&.sign_in_date.try(:to_date),
        display_time_in: last_visit&.sign_in_date&.strftime('%I:%M %p'),
    }
  end

  def self.csv_header
    Visitor.new.to_json.except(:avatar).keys.map{|v| v.to_s.sub('display_', '').sub('_', ' ')}
  end

  def self.signed_in
    includes(:visitor_visit_informations).references(:visitor_visit_informations).where.not(visitor_visit_informations: { sign_in_date: nil })
  end

  def to_csv
    to_json.except(:avatar).values
  end

end
