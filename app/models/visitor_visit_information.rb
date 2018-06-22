class VisitorVisitInformation < ApplicationRecord
  belongs_to :visitor

  belongs_to :person, foreign_key: :person_visiting_id

  def status
    # if (transstatus === "00000") {
    #     arrow-right" 
    # } else if (transstatus === "00002") {
    #    warning-sign" 
    # } else if ((transstatus === "10000") || (transstatus === "01000") || (transstatus === "21000")) {
    #     newinput = newinput + '<td><button class="return_visitin_btn"><span class="glyphicon glyphicon-arrow-right" 
    # } else if ((transstatus === "10002") || (transstatus === "01002") || (transstatus === "21002")) {
    #     newinput = newinput + '<td><button class="missed_signout_btn missed_cr_btn"><span class="glyphicon glyphicon-alert" 
    # } else if (transstatus === "20000") {
    #     newinput = newinput + '<td><button class="update_visitin_btn"><span class="glyphicon glyphicon-arrow-right" 
    # } else if (transstatus === "20002") {
    #     newinput = newinput + '<td><button class="missed2_signout_btn missed_uv_btn"><span class="glyphicon glyphicon-warning-sign" 
    # } else if ((transstatus === "01100") || (transstatus === "10100") || (transstatus === "21100")) {
    #     newinput = newinput + '<td><button class="visitin_recorded_btn"><span class="glyphicon glyphicon-arrow-right" 
    # } else if ((transstatus === "01102") || (transstatus === "10102") || (transstatus === "21102")) {
    #     newinput = newinput + '<td><button class="missed_signout_btn missed_ur_btn"><span class="glyphicon glyphicon-alert" 
    # } else if ((transstatus === "01111") || (transstatus === "10111") || (transstatus === "21111")) {
    #     newinput = newinput + '<td><button class="saved_visit_btn"><span class="glyphicon glyphicon-ok" 
    # } else if (transstatus === "00010") {
    #     newinput = newinput + '<td><button class="first_visitout_btn"><span class="glyphicon glyphicon-arrow-left" 
    # } else if (transstatus === "20010") {
    #     newinput = newinput + '<td><button class="update_visitout_btn"><span class="glyphicon glyphicon-arrow-left" 
    # } else if ((transstatus === "01010") || (transstatus === "10010") || (transstatus === "21010")) {
    #     newinput = newinput + '<td><button class="return_visitout_btn"><span class="glyphicon glyphicon-arrow-left" 
    # } else if ((transstatus === "01110") || (transstatus === "10110") || (transstatus === "21110")) {
    #     newinput = newinput + '<td><button class="return2_visitout_btn"><span class="glyphicon glyphicon-arrow-left" 
    # } else if ((transstatus === "02222") || (transstatus === "12222") || (transstatus === "22222")) {
    #     newinput = newinput + '<td><button class="saved_missed_btn"><span class="glyphicon glyphicon-ok" 


    # First time Visiting
    # Sign in Recorded
    # Sign out
  end
end
