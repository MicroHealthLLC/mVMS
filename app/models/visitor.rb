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
  scope :f_name, ->(name) { where('LOWER(name) LIKE :name_search', name_search: "%#{name.downcase}%") }
  scope :f_company, ->(company) { where('LOWER(company) LIKE :company', company: "%#{company.downcase}%") }
  scope :f_email, ->(email) { where('LOWER(email) LIKE :email', email: "%#{email.downcase}%") }
  scope :f_phone, ->(phone) { where('LOWER(phone) LIKE :phone', phone: "%#{phone.downcase}%") }
  scope :f_date_range, ->(range) {
    dates = range.split('-').map(&:strip)
    date_from = Date.strptime(dates[0], '%m/%d/%Y') rescue nil
    date_to = Date.strptime(dates[1], '%m/%d/%Y') rescue nil
    if date_from && date_to
      where("visitor_visit_informations.sign_in_date BETWEEN ? AND ?", date_from, date_to)
    else
      where(nil)
    end
  }
  scope :f_visit_reason, ->(reason) { where(visitor_visit_informations: {visit_reason: reason}) }
  scope :f_person_visiting, ->(person_id) { where(visitor_visit_informations: {person_visiting_id: person_id}) }
  scope :f_us_citizen, ->(us_citizen) { where('visitors.us_citizen = :value', value: us_citizen) }
  scope :f_classified, ->(classified) { where(visitor_visit_informations: {classified: classified}) }
  scope :sorted_by, ->(sort) { order("#{sort.presence || 'visitors.id'} ASC") }


  after_create do
    save_image_avatar
  end
  # def status
  #   if  classified.nil? or person.nil?
  #     return '02222'
  #   end
  #   return '01111' if sign_out_date.present?
  #   return '10002' if sign_in_date.nil?
  #   return '10002' if sign_in_date.to_date < Date.today.to_date
  #   return '01100' if 2.hours.ago < sign_in_date
  #   "01110"
  # end

  # ['All Visitor Transactions Saved', "#{VisitorVisitInformation::ALL_VISITOR_SAVED}"],
  #     ['All Missed Sign Out Visitor Transactions Saved', "#{VisitorVisitInformation::ALL_MISSED_SIGN_OUT}"],
  #     ['Sign In Recorded*', "#{VisitorVisitInformation::SIGN_IN_RECORDED}"],
  #     ['Must Record Sign Out*', "#{VisitorVisitInformation::MUST_SIGN_OUT}"],
  #     ['Should Update Return Visitor', "#{VisitorVisitInformation::SHOULD_UPDATE_RETURN_VISITOR}"],
  #     ['Missed Sign Out: Must Record Sign In/Out', "#{VisitorVisitInformation::MISSED_SIGN_OUT_MUST_RECORD_SIGN_IN_OUT}"]
  # ],
  scope :f_status, ->(status){
    case status
      when "#{VisitorVisitInformation::SHOULD_UPDATE_RETURN_VISITOR}" then info_missing
      when "#{VisitorVisitInformation::ALL_VISITOR_SAVED}" then all_visitor_saved
      when "#{VisitorVisitInformation::ALL_MISSED_SIGN_OUT}" then all_missed_visitor_saved
      when "#{VisitorVisitInformation::SIGN_IN_RECORDED}" then sign_in_present
      when "#{VisitorVisitInformation::MISSED_SIGN_OUT_MUST_RECORD_SIGN_IN_OUT}" then sign_in_outdate
      when  "#{VisitorVisitInformation::MUST_SIGN_OUT}" then must_sign_out
      when '01110' then where(nil)
      else
        where(nil)
    end
  }

  def self.info_missing
    where("visitor_visit_informations.email = :empty OR visitor_visit_informations.phone = :empty OR visitor_visit_informations.company = :empty OR visitor_visit_informations.name = :empty", empty: '')
  end

  def self.all_visitor_saved
    where("visitor_visit_informations.sign_in_date IS NOT NULL AND visitor_visit_informations.sign_out_date IS NULL").where(visitor_visit_informations: {recorded_by: [nil, '']})
  end

  def self.all_missed_visitor_saved
    where("visitor_visit_informations.sign_in_date IS NOT NULL AND visitor_visit_informations.sign_out_date IS NULL").where.not(visitor_visit_informations: {recorded_by: [nil, '']})
  end

  def self.sign_in_present
    where("visitor_visit_informations.sign_in_date > ? AND visitor_visit_informations.sign_out_date IS NULL AND", 2.hours.ago)
  end

  def self.must_sign_out
    where("visitor_visit_informations.sign_in_date < ? ", 2.hours.ago )
  end

  def self.sign_in_outdate
    where("visitor_visit_informations.sign_in_date IS NULL OR visitor_visit_informations.sign_in_date < ? ", Date.today.to_date )
  end

  scope :f_visits, ->(status){
    case status
      when 'first_visit' then
        v = VisitorVisitInformation.select(" visitor_id, COUNT(*)").group('visitor_id').having('COUNT(*) = 1')
        where(id: v.pluck(:visitor_id))
      when 'return_visitor' then
        v = VisitorVisitInformation.select(" visitor_id, COUNT(*)").group('visitor_id').having('COUNT(*) > 1')
        where(id: v.pluck(:visitor_id))
      when 'need_info' then
        where(nil)
      else
        where(nil)
    end
  }


  default_scope { includes(:visitor_visit_informations).references(:visitor_visit_informations) }
  validates_presence_of :name, :email, :avatar
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

  def save_image_avatar
    storage_path = File.join(Rails.root, "public")
    path = storage_path + "/visitors"
    FileUtils.mkdir_p(path) unless File.directory?(path)
    image = path + "/visitor_#{self.id}.jpg"
    unless FileTest.exist?(image)
      if self.avatar
        data = StringIO.new( Base64.decode64(self.avatar.to_s.sub('data:image/jpeg;base64', '') ))
        File.open(File.join(Rails.root, 'public', 'visitors', "visitor_#{self.id}.jpg"), 'wb') { |f| f.write data.read }
      end
    end
  end

end
