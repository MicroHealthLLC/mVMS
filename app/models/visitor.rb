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
  attr_accessor :last_visits
  include ActionView::Helpers::NumberHelper
  include Filterable
  # Filter scopes
  scope :f_name, ->(name) { where('LOWER(visitors.name) LIKE :name_search', name_search: "%#{name.downcase}%") }
  scope :f_company, ->(company) { where('LOWER(visitors.company) LIKE :company', company: "%#{company.downcase}%") }
  scope :f_email, ->(email) { where('LOWER(visitors.email) LIKE :email', email: "%#{email.downcase}%") }
  scope :f_phone, ->(phone) { where('LOWER(visitors.phone) LIKE :phone', phone: "%#{phone.downcase}%") }
  scope :f_date_range, ->(range) {
    dates = range.split('-').map(&:strip)
    date_from = Date.strptime(dates[0], '%m/%d/%Y') rescue nil
    date_to = Date.strptime(dates[1], '%m/%d/%Y') rescue nil
    if date_from && date_to
      where("visitor_visit_informations.sign_in_date BETWEEN ? AND ?", date_from.to_time, date_to.to_time.end_of_day)
    else
      where(nil)
    end
  }
  scope :f_visit_reason, ->(reason) do
    if reason == 'Other'
      where.not(visitor_visit_informations: {visit_reason: Reason.pluck(:name)})
    else
      where(visitor_visit_informations: {visit_reason: reason})
    end
  end
  scope :f_person_visiting, ->(person_id) { where(visitor_visit_informations: {person_visiting_id: person_id}) }
  scope :f_us_citizen, ->(us_citizen) { where('visitors.us_citizen = :value', value: us_citizen) }
  scope :f_classified, ->(classified) { where(visitor_visit_informations: {classified: classified}) }
  scope :sorted_by, ->(sort) { order("#{ sort.present? ? "#{sort}" : 'visitor_visit_informations.sign_in_date DESC, visitor_visit_informations.sign_out_date DESC'}") }

  scope :f_status, ->(status){
    case status
    when "#{VisitorVisitInformation::SIGN_IN_RECORDED}" then sign_in_present
    when  "#{VisitorVisitInformation::SIGN_IN_OUT_RECORDED}" then sign_out_recorded
    when  "#{VisitorVisitInformation::MUST_SIGN_OUT}" then must_sign_out
    when  "#{VisitorVisitInformation::ADMIN_SIGN_IN_OUT_RECORDED}" then must_sign_out
    else
      where(nil)
    end
  }

  scope :f_visits, ->(status){
    case status
    when 'first_visit' then
      v = VisitorVisitInformation.select(" visitor_id, COUNT(*)").group('visitor_id').having('COUNT(*) = 1')
      where(id: v.pluck(:visitor_id))
    when 'return_visitor' then
      v = VisitorVisitInformation.select(" visitor_id, COUNT(*)").group('visitor_id').having('COUNT(*) > 1')
      where(id: v.pluck(:visitor_id))
    when 'need_info' then
      v = VisitorVisitInformation.select(" visitor_id, COUNT(*)").group('visitor_id').having('COUNT(*) > 1')
      where(id: v.pluck(:visitor_id)).where({info_updated: false})
    else
      where(nil)
    end
  }

  after_create do
    save_image_avatar
  end

  def name
    n = super
    n.to_s.split.map(&:capitalize)*' '
  end

  def self.info_missing
    where("visitors.email = :empty OR visitors.phone = :empty OR visitors.company = :empty OR visitors.name = :empty OR visitors.info_updated = :info_updated", empty: '', info_updated: false)
  end

  def self.return_visitor_need_indate_info_then_sign_out
    info_missing.must_sign_out
  end

  def self.all_visitor_saved
    where("visitor_visit_informations.sign_in_date IS NOT NULL AND visitor_visit_informations.sign_out_date IS NOT NULL").where(visitor_visit_informations: {recorded_by: [nil, '']})
  end

  def self.all_missed_visitor_saved
    where("visitor_visit_informations.sign_in_date IS NOT NULL AND visitor_visit_informations.sign_out_date IS NOT NULL").
        where.not(visitor_visit_informations: {recorded_by: [nil, '']})
  end

  def self.sign_in_present
    where("visitor_visit_informations.sign_in_date > ? AND visitor_visit_informations.sign_out_date IS NULL", 2.hours.ago)
  end

  def self.must_sign_out
    where("visitor_visit_informations.sign_in_date < ? AND visitor_visit_informations.sign_in_date > ? AND visitor_visit_informations.sign_out_date IS NULL", 2.hours.ago, Date.today.to_date )
  end

  def self.sign_out_recorded
    where("visitor_visit_informations.sign_out_date IS NOT NULL" ).where(visitor_visit_informations: {recorded_by: [nil, '']})
  end

  def self.admin_sign_out_recorded
    where("visitor_visit_informations.sign_out_date IS NOT NULL" ).where.not(visitor_visit_informations: {recorded_by: [nil, '']})
  end

  def self.sign_out_outdate
    where("visitor_visit_informations.sign_out_date IS NULL AND (visitor_visit_informations.sign_in_date IS NULL OR visitor_visit_informations.sign_in_date < ?) ", Date.today.to_date )
  end

  def self.init_vvi
    @last_visits = VisitorVisitInformation.where(id: VisitorVisitInformation.select('MAX(id) AS id').group('visitor_id').map(&:id) )
    includes(:visitor_visit_informations).references(:visitor_visit_informations).where(visitor_visit_informations: {id: @last_visits})
  end

  validates_presence_of :name, :email
  validates_presence_of :avatar, on: :create
  validates_presence_of :phone
  validate :validate_phone_number
  validates_uniqueness_of :email

  def validate_phone_number
    tel = phone.to_s.strip.gsub(/ *-*\.*/, '')
    number_to_phone(tel, raise: true) rescue errors.add(:base, 'Phone number is not valid')
  end

  def personvisiting
    visitor_visit_informations.last.try(:person_visiting)
  end

  def has_visit_missed?
    visitor_visit_informations.where(sign_out_date: nil).present?
  end

  def last_visit
    @last_visit ||= visitor_visit_informations.order(:sign_in_date).last || VisitorVisitInformation.new
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
    {
        display_name: self.name,
        display_company: self.company,
        display_phone: self.phone,
        avatar: self.avatar,
        display_email: self.email,

        display_reason: last_visit&.visit_reason,
        display_personvisit: last_visit&.person.try(:name),
        display_citizen: (self.us_citizen == 'true'),

        display_classified: last_visit&.classified?,
        display_date_in: last_visit&.sign_in_date.try(:to_date),
        display_time_in: last_visit&.sign_in_date&.strftime('%I:%M %p'),
        display_date_out: last_visit&.sign_out_date.try(:to_date),
        display_time_out: last_visit&.sign_out_date&.strftime('%I:%M %p')
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
