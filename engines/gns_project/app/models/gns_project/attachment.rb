module GnsProject
  class Attachment < ApplicationRecord
    belongs_to :task
    
    validates :file, :presence => true
  end
end
