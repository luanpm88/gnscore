domestic = GnsContact::Category.create(
  name: 'Trong nước'
) if GnsContact::Category.where(name: 'Trong nước').empty?

foreign = GnsContact::Category.create(
  name: 'Nước ngoài'
) if GnsContact::Category.where(name: 'Nước ngoài').empty?

hki = GnsContact::Contact.new(
  code: 'HKI',
  full_name: 'Công ty Hoàng Khang',
  foreign_name: 'Hoang Khang Incotech',
  contact_type: GnsContact::Contact::TYPE_COMPANY
)
hki.categories << domestic
hki.save