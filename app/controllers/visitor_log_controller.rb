class VisitorLogController < ApplicationController
  def index
    @visitors = Visitor.all
    render 'visitor_log/visitor_log'
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
