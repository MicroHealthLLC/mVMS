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
  RETURN_VISITOR_NEED_INFO_UPDATE = '11001'

  SHOULD_UPDATE_RETURN_VISITOR = '0000'
  SIGN_IN_RECORDED = '0001'
  SIGN_IN_OUT_RECORDED = '0010'
  ADMIN_SIGN_IN_OUT_RECORDED = '0011'
  MUST_SIGN_OUT = '0100'
  RETURN_VISITOR_NEED_INFO_UPDATE_THEN_RECORD_SIGN_IN_OUT = '0101'
  ALL_VISITOR_SAVED = '1111'
  ALL_MISSED_SIGN_OUT = '2222'
  MISSED_SIGN_OUT_MUST_RECORD_SIGN_IN_OUT ='0110'

  def self.global_status
      if where(sign_out_date: nil).blank?
        ALL_VISITOR_SAVED
      else
        ALL_MISSED_SIGN_OUT
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
    if  sign_in_date.present? && sign_out_date.present?
      return MISSED_SIGN_OUT_MUST_RECORD_SIGN_IN_OUT if  sign_out_date < sign_in_date
      if visitor.email.blank? || visitor.phone.blank? || visitor.company.blank? || visitor.name.blank?
        return SHOULD_UPDATE_RETURN_VISITOR
      else
        if recorded_by
          return ADMIN_SIGN_IN_OUT_RECORDED
        end
        return SIGN_IN_OUT_RECORDED
      end
    end

    if sign_in_date.nil? && sign_out_date.nil?
      if visitor.email.blank? || visitor.phone.blank? || visitor.company.blank? || visitor.name.blank?
        return RETURN_VISITOR_NEED_INFO_UPDATE_THEN_RECORD_SIGN_IN_OUT
      else
        return MISSED_SIGN_OUT_MUST_RECORD_SIGN_IN_OUT
      end
    elsif sign_in_date.present?
      if sign_out_date.nil?
        if sign_in_date.to_date < 1.day.ago
          return MISSED_SIGN_OUT_MUST_RECORD_SIGN_IN_OUT
        else
          if sign_in_date < 2.hours.ago
          else
            SIGN_IN_RECORDED
          end
          return MUST_SIGN_OUT
        end
      end
    elsif sign_out_date.present?
      return MISSED_SIGN_OUT_MUST_RECORD_SIGN_IN_OUT
    end
  end

  def status
    VisitorVisitInformation.where(visitor_id: visitor.id).where('id <= ?', self.id).count > 1 ? "1#{visitor_status}" : "0#{visitor_status}"
  end


end
