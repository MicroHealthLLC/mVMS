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

  def visitor_lof_all_statuses

  end
end
