FactoryBot.define do

  factory :visitor do
    name { "bilel" }
    company { "BS" }
    phone { "555555555" }
    email { "bilel.kedidi@gmail.com" }
    us_citizen { "bilel" }
    avatar {'xases6r4pt9PjnW3u5YVdxIESVl3NgDJA9gBz6Uo1LRsTKnzO5B4c'}
    info_updated {true}
  end

  factory :visitor_visit_information do
    classified {true}
    us_citizen {true}
    visit_reason {'test'}
    person_visiting_id {1}
    end
  factory :person do
    name { 'Franck tucker'}
  end
end