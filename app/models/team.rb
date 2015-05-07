class Team < ActiveRecord::Base

  validates :number, presence: true, uniqueness: true, numericality: true
  validates :name, presence: true, uniqueness: {case_sensitive: false}
  
end
