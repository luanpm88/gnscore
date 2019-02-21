module GnsContact
  class Contact < ApplicationRecord
    validates :full_name, :presence => true
  end
end
