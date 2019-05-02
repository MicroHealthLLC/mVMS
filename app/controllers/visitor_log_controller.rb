class VisitorLogController < BaseController
  before_action :authenticate_user!

  def index

  end

  def visitor_transactions
    @visitor = Visitor.find_by_id params[:personid]
    if @visitor
      storage_path = File.join(Rails.root, "public")
      path = storage_path + "/visitors"
      unless File.directory?(path)
        FileUtils.mkdir_p(path)
      end

      image = path + "/visitor_#{@visitor.id}.jpeg"
      unless FileTest.exist?(image)
        if @visitor.avatar
          data = StringIO.new( Base64.decode64(@visitor.avatar.to_s.sub('data:image/jpeg;base64', '') ))
          File.open(File.join(Rails.root, 'public', 'visitors', "visitor_#{@visitor.id}.jpeg"), 'wb') { |f| f.write data.read }
        end

      end
    end

  end

  def visitor_log
    require 'csv'
    @visitors = Visitor.filter(filter_params).paginate(page: params[:page], per_page: 15)
    respond_to do |format|
      format.html{}
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

  def visitors_log_all_statuses
    @visitors = Visitor.all
  end

  private

  def filter_params
    @filters ||= Filter.new(params.fetch(:filter, {})).tap do |filters|
    end
  end
end
