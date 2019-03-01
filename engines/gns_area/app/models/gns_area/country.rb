module GnsArea
  class Country < ApplicationRecord
    has_many :states, class_name: 'GnsArea::States', dependent: :restrict_with_error
    
    validates :name, :presence => true

  end
end
