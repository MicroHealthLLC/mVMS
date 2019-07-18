# == Schema Information
#
# Table name: people
#
#  id         :bigint(8)        not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Person < ApplicationRecord
  validates_presence_of :email, :name
  validates_uniqueness_of :email
end
