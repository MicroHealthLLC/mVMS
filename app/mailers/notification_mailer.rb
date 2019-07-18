class NotificationMailer < ApplicationMailer
  def notify_person(vvi_id, visitor_id, person_id)
    @vvi = VisitorVisitInformation.find vvi_id
    @person = Person.find person_id
    @visitor = Visitor.find(visitor_id)
    mail(to: @person.email, subject: "New visit")
  end
end
