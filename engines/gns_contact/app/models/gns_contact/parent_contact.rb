module GnsContact
  class ParentContact < ApplicationRecord
    belongs_to :parent, class_name: 'GnsContact::Contact', optional: true
    belongs_to :child, class_name: 'GnsContact::Contact', foreign_key: :contact_id, optional: true
  end
end
