module GnsProject
  class Attachment < ApplicationRecord
    belongs_to :task
    
    validates :name, :presence => true
  end
end
