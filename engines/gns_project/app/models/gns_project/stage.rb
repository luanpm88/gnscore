module GnsProject
  class Stage < ApplicationRecord
    belongs_to :category
    
    validates :name, :category_id, :presence => true
  end
end
