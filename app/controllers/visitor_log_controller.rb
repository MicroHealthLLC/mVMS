class VisitorLogController < BaseController
  before_action :authenticate_user!

  def index

  end

  def visitor_transactions
    visitor = Visitor.find_by_id params[:personid]
    if visitor
      storage_path = File.join(Rails.root, "public")
      path = storage_path + "/visitors"
      unless File.directory?(path)
        FileUtils.mkdir_p(path)
      end

      image = path + "/visitor_#{visitor.id}.jpeg"
      unless FileTest.exist?(image)
        data = StringIO.new( Base64.decode64(visitor.avatar.sub('data:image/jpeg;base64', '') ))
        File.open(File.join(Rails.root, 'public', 'visitors', "visitor_#{visitor.id}.jpeg"), 'wb') { |f| f.write data.read }
      end
    end

  end

  def visitor_log
    require 'csv'
    @visitors = Visitor.where(nil)
    respond_to do |format|
      format.html{}
      format.csv{
       @csv =  CSV.generate do |csv|
         csv << Visitor.csv_header
          @visitors.signed_in.each do |visitor|
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
end
