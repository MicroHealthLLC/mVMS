class VisitorLogController < BaseController
  before_action :authenticate_user!

  def index
    require 'csv'
    @visitors = Visitor.filter(filter_params).sorted_by(params[:sort_by]).paginate(page: params[:page], per_page: 15)
    respond_to do |format|
      format.html{

      }
      format.csv{
        @csv =  CSV.generate do |csv|
          csv << Visitor.csv_header
          @visitors.filter(filter_params).signed_in.each do |visitor|
            csv<< visitor.to_csv
          end
        end
        send_data @csv, filename: 'visitor_log.csv'
      }
    end
  end

  def visitor_transactions
    @visitor = Visitor.find_by_id params[:personid]
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
