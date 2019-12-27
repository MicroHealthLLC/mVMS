module VisitorLogHelper
  def show_sign_in_status(visit)
    if visit.status[0] == "0"
      '<span class="new_user_btn"><span class="glyphicon glyphicon-user" aria-hidden="true"></span></span>'.html_safe
    else
      '<span class="return_user_btn"><span class="glyphicon glyphicon-user" aria-hidden="true"></span></span>'.html_safe
    end
  end
 def show_visit_status(visit)
   case visit.status[1..-1]
   when  VisitorVisitInformation::SIGN_IN_OUT_RECORDED  then '<span class="visitor_signout_recored_btn"><span class="glyphicon glyphicon-arrow-left" aria-hidden="true"></span></span>'.html_safe
   when  VisitorVisitInformation::MUST_SIGN_OUT  then '<span class="missed_signout_btn"><span class="glyphicon glyphicon-alert" aria-hidden="true"></span></span>'.html_safe
   when  VisitorVisitInformation::ADMIN_SIGN_IN_OUT_RECORDED  then '<span class="missed2_signout_btn"><span class="glyphicon glyphicon-circle-arrow-left" aria-hidden="true"></span></span>'.html_safe
   else
     'hello'
   end
  end
end
