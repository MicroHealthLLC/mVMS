require 'rails_helper'

# FIRST_TIME_VISITOR = '00111'
# RETURN_VISITOR = '11000'
# RETURN_VISITOR_NEED_INFO_UPDATE = '11001'
#
# SHOULD_UPDATE_INFO_VISITOR = '0000'
# SIGN_IN_RECORDED = '0001'
# SIGN_IN_OUT_RECORDED = '0010'
#
# ADMIN_SIGN_IN_OUT_RECORDED = '0011'
# MUST_SIGN_OUT = '0100'
# RETURN_VISITOR_NEED_INFO_UPDATE_THEN_RECORD_SIGN_IN_OUT = '0101'
#
# ALL_VISITOR_SAVED = '1111'
# ALL_MISSED_SIGN_OUT = '2222'
# MISSED_SIGN_OUT_MUST_RECORD_SIGN_IN_OUT ='0110'

RSpec.describe VisitorVisitInformation, type: :model do
  context 'Check status' do
    before do
      @person = create(:person)
      @visitor = create(:visitor)
    end

    it ' i sign in and i do not sign out after 1 day' do
      @vvi = build(:visitor_visit_information, visitor_id: @visitor.id, sign_in_date: 1.day.ago, person_visiting_id: @person.id)
      expect(@vvi.status).to eq("0#{VisitorVisitInformation::MISSED_SIGN_OUT_MUST_RECORD_SIGN_IN_OUT}")
    end
    it ' i sign in and do not sign out after 2 hours' do
      @vvi = build(:visitor_visit_information, visitor_id: @visitor.id, sign_in_date: 3.hours.ago, person_visiting_id: @person.id)
      expect(@vvi.status).to eq("0#{VisitorVisitInformation::MUST_SIGN_OUT}")
    end
    it ' i sign 30 mn ago' do
      @vvi = build(:visitor_visit_information, visitor_id: @visitor.id, sign_in_date: 1.hour.ago, person_visiting_id: @person.id)
      expect(@vvi.status).to eq("0#{VisitorVisitInformation::SIGN_IN_RECORDED}")
    end

    it ' i sign in but sign out by admin' do
      @vvi = build(:visitor_visit_information, visitor_id: @visitor.id, sign_in_date: 3.hours.ago, sign_out_date: 1.hours.ago, info_updated: true, person_visiting_id: @person.id, recorded_by: 'admin')
      # binding.pry
      expect(@vvi.status).to eq("0#{VisitorVisitInformation::ADMIN_SIGN_IN_OUT_RECORDED}")
    end


    it ' i sign in but sign out with info updated = false' do
      @vvi = build(:visitor_visit_information, visitor_id: @visitor.id, sign_in_date: 3.hours.ago,
                   sign_out_date: 1.hours.ago, info_updated: false, person_visiting_id: @person.id)
      expect(@vvi.status).to eq("0#{VisitorVisitInformation::SIGN_IN_OUT_RECORDED}")
    end

   it ' i sign in with info updated = false' do
      @vvi = build(:visitor_visit_information, visitor_id: @visitor.id,
                   sign_in_date: 3.hours.ago, info_updated: false, person_visiting_id: @person.id)
      # binding.pry
      expect(@vvi.status).to eq("0#{VisitorVisitInformation::MISSED_SIGN_OUT_MUST_RECORD_SIGN_IN_OUT}")
    end


   it ' i sign in with info updated = true' do
      @vvi = build(:visitor_visit_information, visitor_id: @visitor.id,
                   sign_in_date: 1.hours.ago, info_updated: true, person_visiting_id: @person.id)
      # binding.pry
      expect(@vvi.status).to eq("0#{VisitorVisitInformation::RETURN_VISITOR_NEED_INFO_UPDATE_THEN_RECORD_SIGN_IN_OUT}")
    end


    it ''
    it ''
  end
end
