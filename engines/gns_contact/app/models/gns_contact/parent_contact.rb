module GnsContact
  class ParentContact < ApplicationRecord
    belongs_to :parent, class_name: 'GnsContact::Contact'
    belongs_to :child, class_name: 'GnsContact::Contact', foreign_key: :contact_id
  end
end
