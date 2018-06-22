class VisitorVisitInformation < ApplicationRecord
  belongs_to :visitor

  belongs_to :person, foreign_key: :person_visiting_id
end
