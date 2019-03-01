ActiveRecord::Base.logger = nil

# Create countries
if GnsArea::Country.where(name: 'Việt Nam').empty?
  vn = GnsArea::Country.create(name: 'Việt Nam')
  puts "Total #{GnsArea::Country.count} countries in the table"
else
  vn = GnsArea::Country.find_by_name('Việt Nam')
  puts "Total #{GnsArea::Country.count} countries in the table"
end

# =====================================================================================================
# Import states
xlsx_states = Roo::Spreadsheet.open('engines/gns_area/database/danh_sach_cap_tinh_2019_02_28.xlsx')
# Read excel file. sheet tabs loop
xlsx_states.each_with_pagename do |name, sheet|
  thutu_tinh = 0
  
  sheet.each_row_streaming do |row|
    if row[1].value == vn.id # kiem tra xem co phai ma quoc gia la cua Viet Nam khong (ID Viet Nam vua tao o tren)
      if GnsArea::State.where(name: "#{row[0].value}").empty? # kiem tra xem ten tinh/thanhpho da ton tai chua /neu chua thi tao
        st = GnsArea::State.create(
          name: row[0].value,
          country_id: row[1].value
        )
        thutu_tinh += 1
      end
    end    
  end
  puts '-----'
  puts "#{thutu_tinh} states have been imported"
  puts "Total #{GnsArea::State.count} states in the table"
end

# =====================================================================================================
# Import districts      
xlsx_districts = Roo::Spreadsheet.open('engines/gns_area/database/danh_sach_cap_huyen_2019_02_28.xlsx')
# Read excel file. sheet tabs loop
xlsx_districts.each_with_pagename do |name, sheet|
  thutu_huyen = 0
  sheet.each_row_streaming do |row|
    if GnsArea::District.where('gns_area_districts.name = ? AND gns_area_districts.state_id = ? ', row[0].value, row[1].value).empty? # kiem tra xem ten quan/huyen da ton tai chua /neu chua thi tao
      GnsArea::District.create(
        name: row[0].value,
        state_id: row[1].value
      )
      thutu_huyen += 1
    end
  end
  puts '-----'
  puts "#{thutu_huyen} districts have been imported"
  puts "Total #{GnsArea::District.count} districts in the table"
end