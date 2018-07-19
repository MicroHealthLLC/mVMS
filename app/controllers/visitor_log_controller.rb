class VisitorLogController < BaseController
  before_action :authenticate_user!

  def index

  end

  def visitor_transactions

  end

  def visitor_log
    @visitors = Visitor.all
  end

  def visitors_log_all_statuses
    @visitors = Visitor.all
  end
end
