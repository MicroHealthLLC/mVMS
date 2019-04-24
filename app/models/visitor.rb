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

  include Filterable
  # Filter scopes
  scope :f_name, ->(name) { where('LOWER(name) LIKE :name_search', name_search: "#{name.downcase}%") }
  scope :f_company, ->(company) { where('LOWER(company) LIKE :company', company: "#{company.downcase}%") }
  scope :f_email, ->(email) { where('LOWER(email) LIKE :email', email: "#{email.downcase}%") }
  scope :f_phone, ->(phone) { where('LOWER(phone) LIKE :phone', phone: "#{phone.downcase}%") }
  scope :f_date_range, ->(range) {
    dates = range.split('-').map(&:strip)
    date_from = Date.strptime(dates[0], '%m/%d/%Y') rescue nil
    date_to = Date.strptime(dates[1], '%m/%d/%Y') rescue nil
    if date_from && date_to
      joins(:visitor_visit_informations).where(visitor_visit_informations: {sign_out_date: nil}).where("visitor_visit_informations.sign_in_date BETWEEN ? AND ?", date_from, date_to)
    else
      where(nil)
    end
  }

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
