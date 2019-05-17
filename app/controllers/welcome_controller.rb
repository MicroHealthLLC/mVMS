class WelcomeController < ApplicationController
  before_action :authenticate_user!, only: [:update_visitor]

  def index
  end

  def visitor_sign_form

  end

  def visitors

  end

  def visitor_signout
    @visitors = Visitor.joins(:visitor_visit_informations).merge(VisitorVisitInformation.where(sign_out_date: nil))
    if request.post?
      name = params[:name]
      if name.strip.present?
        @visitor = @visitors.where(email: name).first
        if @visitor.nil?
          flash[:error] = 'You are not signed in. Click Cancel'
          redirect_to "/visitor_signout"
        end
      else
        flash[:error] = 'Email should not be blank'
        redirect_to "/visitor_signout"

      end

    else
      if params[:visitor_id]
        @visitor = Visitor.find(params[:visitor_id])
        @visitor.visitor_visit_informations.where( sign_out_date: nil ).update_all({sign_out_date: Time.now })
        redirect_to root_path
        return
      end
    end

  end

  def update_visitor
    visitor = Visitor.find_by_id params[:record_visit_id]
    if visitor
      last_visits = visitor.visitor_visit_informations.where( sign_out_date: nil )
      options = {
          visit_reason: params[:record_reason],
          classified: params[:classified],
          person_visiting_id: Person.find_by_name( params[:person_visiting]).id,
          recorded_by: current_user.full_name
      }
      if params[:record_datetime_in].present? && params[:record_datetime_in] != 'NaN'
        sign_in_date = Time.at(params[:record_datetime_in][0..-4].to_i) rescue nil
        options.merge!({sign_in_date: sign_in_date}) if sign_in_date
      end

      if params[:record_datetime_out].present? && params[:record_datetime_out] != 'NaN'
        sign_out_date = Time.at(params[:record_datetime_out][0..-4].to_i) rescue nil
        options.merge!({sign_out_date: sign_out_date}) if sign_out_date
      end
      if last_visits.present?

        last_visits.update_all(options)
      else
        last_visit = visitor.visitor_visit_informations.last
        last_visit.update(options)
      end

    end
    redirect_back(fallback_location: '/visitor_log')
  end
  def visitor_bye

  end

  def check_visitor
    visitor = Visitor.where({
                                email: params[:email].to_s.strip
                            }).first_or_initialize
    json = if params[:first_visit].to_s == 'false' and visitor.persisted?
             {success: true}
           elsif params[:first_visit].to_s == 'true' and visitor.persisted?
             {success: false, message: "It seems that this is not your first visit. You can update your data.", should_signout: false}
           elsif params[:first_visit].to_s == 'false' and visitor.new_record?
             {success: false, message: "We didn't find your email in our DB, we will create a new record. ", should_signout: false}
           elsif visitor.persisted? && visitor.visitor_visit_informations.where(sign_out_date: nil).present?
             {success: false, message: "You have to signout before sign in again", should_signout: true}
           else
             {success: true}
           end
    json.merge!({
                    phone: visitor.phone,
                    company: visitor.company,
                    name: visitor.name,
                    us_citizen: visitor.us_citizen?
                })
    render json:  json
  end

  def get_visitor_info
    @visitor = Visitor.find_by_email(params[:email])
    if @visitor
      if @visitor.has_visit_missed?
        render json: {success: true, data: @visitor.to_json}
      else
        render json: {success: false, errors: 'There is not missed visit found'}
      end

    else
      render json: {success: false, errors: 'User not found'}
    end

  end

  def create_visitor
    visitor = Visitor.where({
                                email: params[:email].to_s.strip
                            }).first_or_initialize
    if params[:update_contact].to_s == 'true' or visitor.new_record?
      visitor.attributes = {
          phone: params[:phone],
          company: params[:company],
          name: params[:person_name],
          us_citizen: params[:citizen],
          person_signature: params[:person_signature],
          avatar: params[:person_image_url]
      }
    end
    visitor.save
    if visitor.persisted?
      visitor.visitor_visit_informations.create({
                                                    visit_reason: params[:reason],
                                                    classified: !(params[:classified]== 'no'),
                                                    person_visiting_id: Person.find_by_name(params[:person_visiting]).try(:id),
                                                    sign_in_date: Time.now
                                                })
      render json: {success: true, visitor: visitor.id }
    else
      render json: {success: false, errors: visitor.errors.full_messages  }
    end

  end

  def update_visitor_visit
    visitor = Visitor.where({
                                email: params[:email].to_s.strip
                            }).first_or_initialize
    if visitor.persisted? and last_visit = visitor.last_missed_visit

      last_visit.update({     sign_out_date: Time.at(params[:datetime_out].to_i/1000) })
      render json: {success: true, visitor: visitor.id }
    else
      render json: {success: false, errors: 'Visitor Not found or no missed visit found' }
    end
  end

  def visitor_badge
    @visitor = Visitor.find(params[:visitor_id])
    respond_to do |format|
      format.html{}
      format.pdf{
      }
    end
  end

  def check_email
    respond_to do |format|
      format.json{

      }
      format.js{
        @visitor = Visitor.find_by_email params[:email]
      }
    end
  end
end
