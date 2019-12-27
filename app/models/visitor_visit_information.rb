# == Schema Information
#
# Table name: visitor_visit_informations
#
#  id                 :bigint(8)        not null, primary key
#  visitor_id         :integer
#  date               :datetime
#  visit_reason       :string(255)
#  person_visiting_id :integer
#  us_citizen         :boolean
#  classified         :boolean
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  sign_in_date       :datetime
#  sign_out_date      :datetime
#  recorded_by        :string(255)
#

class VisitorVisitInformation < ApplicationRecord
  belongs_to :visitor

  belongs_to :person, foreign_key: :person_visiting_id

  FIRST_TIME_VISITOR = '00111'
  RETURN_VISITOR = '11000'

  SIGN_IN_RECORDED = '0001'
  SIGN_IN_OUT_RECORDED = '0010'
  MUST_SIGN_OUT = '0100'
  ADMIN_SIGN_IN_OUT_RECORDED = '0011'

  include Filterable

  scope :f_name, ->(name) { where('LOWER(visitors.name) LIKE :name_search', name_search: "%#{name.downcase}%") }
  scope :f_company, ->(company) { where('LOWER(visitors.company) LIKE :company', company: "%#{company.downcase}%") }
  scope :f_email, ->(email) { where('LOWER(visitors.email) LIKE :email', email: "%#{email.downcase}%") }
  scope :f_phone, ->(phone) { where('LOWER(visitors.phone) LIKE :phone', phone: "%#{phone.downcase}%") }
  scope :f_date_range, ->(range) {
    dates = range.split('-').map(&:strip)
    date_from = Date.strptime(dates[0], '%m/%d/%Y') rescue nil
    date_to = Date.strptime(dates[1], '%m/%d/%Y') rescue nil
    if date_from && date_to
      where("sign_in_date BETWEEN ? AND ?", date_from.to_time, date_to.to_time.end_of_day)
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
    when  "#{VisitorVisitInformation::ADMIN_SIGN_IN_OUT_RECORDED}" then admin_sign_out_recorded
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

  validate :check_time
  # validate :check_signout

  def check_time
    if sign_out_date.present? && sign_in_date.present?
      if sign_out_date < sign_in_date
        errors.add(:base, 'Time Sign out is not correct')
      end
    end
  end

  # def check_signout
  #   errors.add(:base, 'You should signout')
  # end

  after_create :send_notification


  def send_notification
    if person && person.email.present?
      NotificationMailer.notify_person(self.id, self.visitor_id, person.id).deliver_now
    end
  end

  def self.global_visit_status
    if where(nil).count > 1
      FIRST_TIME_VISITOR
    else
      RETURN_VISITOR
    end
  end

  def visitor_status
    if sign_in_date.present? && sign_out_date.present?
      return MUST_SIGN_OUT if sign_out_date <= sign_in_date
      if recorded_by
        return ADMIN_SIGN_IN_OUT_RECORDED
      end
      return SIGN_IN_OUT_RECORDED
    end
    if sign_in_date.nil? && sign_out_date.nil?
        return MUST_SIGN_OUT
    elsif sign_in_date.present?
      if sign_out_date.nil?
        if sign_in_date.to_date <= 1.day.ago.to_date
          return MUST_SIGN_OUT
        else
            return SIGN_IN_RECORDED
        end
      end
    elsif sign_out_date.present?
      return MUST_SIGN_OUT
    end
  end

  def status
    VisitorVisitInformation.where(visitor_id: visitor.id).where('id <= ?', self.id).count > 1 ? "1#{visitor_status}" : "0#{visitor_status}"
  end



#  def self.missed_sign_out
#    where("(visitor_visit_informations.sign_in_date IS NOT NULL AND visitor_visit_informations.sign_out_date IS NULL AND visitor_visit_informations.sign_in_date < ?) OR ( visitor_visit_informations.sign_in_date < visitor_visit_informations.sign_out_date )   OR (visitor_visit_informations.sign_in_date IS NULL)
# ",
#
#          Date.today)
#  end


  def self.missed_sign_out
    where("(visitor_visit_informations.sign_in_date IS NOT NULL AND visitor_visit_informations.sign_out_date IS NULL AND visitor_visit_informations.sign_in_date < ?)",
          Date.today)
  end

  def self.saved_sign_out
    where("visitor_visit_informations.sign_in_date IS NOT NULL AND visitor_visit_informations.sign_out_date IS NOT NULL")
  end
end
