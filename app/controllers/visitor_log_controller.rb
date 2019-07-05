class VisitorLogController < BaseController
  before_action :authenticate_user!

  def index
    require 'csv'
    respond_to do |format|
      format.html{
        @visitors = Visitor.init_vvi.filter(filter_params).sorted_by(params[:sort_by]).paginate(page: params[:page], per_page: 15)

      }
      format.csv{
        @csv =  CSV.generate do |csv|
          csv << Visitor.csv_header
          Visitor.unscoped.includes(visitor_visit_informations: [:person]).references(visitor_visit_informations: [:person]).filter(filter_params).sorted_by(params[:sort_by]).signed_in.each do |visitor|
            csv<< visitor.to_csv
          end
        end
        send_data @csv, filename: 'visitor_log.csv'
      }
    end
  end

  def admin
    redirect_to '/visitor_log'
  end

  def visitor_transactions
    @visitor = Visitor.find_by_id params[:personid]
    scope = VisitorVisitInformation.where(visitor_id: @visitor.id).order('sign_in_date DESC')
    filter = params[:visitorsignid]
    case filter
      when 'mso' then  scope = scope.missed_sign_out
      when 'sso' then  scope = scope.saved_sign_out
      when 'cuv' then  scope = scope.where(updated: true)
      else

    end
    @visitors_transactions = scope.paginate(page: params[:page], per_page: 10)
    if @visitor
      if @visitor.avatar
        @visitor.save_image_avatar
      end
    end
  end

  def visitor_log
    index
  end

  def visitors_log_all_statuses
    @visitors = Visitor.all
  end

  private

  def filter_params
    @filters ||= Filter.new(params.fetch(:filter, {})).tap do |filters|
    end
  end
end
