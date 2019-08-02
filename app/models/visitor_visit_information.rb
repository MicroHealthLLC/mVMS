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




  validate :check_time

  def check_time
    if sign_out_date.present? && sign_in_date.present?
      if sign_out_date < sign_in_date
        errors.add(:base, 'Time Sign out is not correct')
      end
    end
  end

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
      return MUST_SIGN_OUT if sign_out_date < sign_in_date
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



  def self.missed_sign_out
    where("visitor_visit_informations.sign_in_date IS NOT NULL AND visitor_visit_informations.sign_out_date IS NULL")
  end

  def self.saved_sign_out
    where("visitor_visit_informations.sign_in_date IS NOT NULL AND visitor_visit_informations.sign_out_date IS NOT NULL")
  end
end
