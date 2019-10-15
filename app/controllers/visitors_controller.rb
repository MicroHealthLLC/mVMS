class VisitorsController < BaseController
  before_action :authenticate_user!
  before_action :find_visitor
  def edit

  end

  def update
    @visitor.update(visitor_params)
    VisitorVisitInformation.where(:visitor_id => @visitor.id).update_all({
        name: @visitor.name,
        company: @visitor.company,
        phone: @visitor.phone,
        us_citizen: @visitor.us_citizen
                                                                         })
    redirect_to "/visitor_log/visitor_transactions?personid=#{@visitor.id}"
  end

  def destroy
    @visitor.destroy
    redirect_to '/admin'
  end

  private
  def find_visitor
    @visitor = Visitor.find params[:id]
  end

  def visitor_params
    params.require(:visitor).permit!
  end
end
