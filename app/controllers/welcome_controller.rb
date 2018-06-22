class WelcomeController < ApplicationController
  before_action :authenticate_user!
  def index
  end

  def visitor_sign_form

  end

  def visitors

  end

  def visitor_bye

  end

  def create_visitor
    visitor = Visitor.where({
                                email: params[:email],
                                phone: params[:phone],
                                company: params[:company],
                                name: params[:person_name],
                                us_citizen: params[:us_citizen]
                            }).first_or_initialize
    visitor.avatar ||= params[:person_image_url]

    visitor.save if visitor.new_record?
    visitor.visitor_visit_informations.create({
                                                  visit_reason: params[:reason],
                                                  classified: params[:classified],
                                                  person_visiting_id: Person.find_by_name(params[:person_visiting]).try(:id),
                                                  sign_in_date: Time.now
                                              })
    render json: {success: true, visitor: visitor.id }
  end

  def visitor_badge
    @visitor = Visitor.find(params[:visitor_id])
  end
end
