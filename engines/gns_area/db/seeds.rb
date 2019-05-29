ActiveRecord::Base.logger = nil

# Create countries
if GnsArea::Country.where(name: 'Việt Nam').empty?
  vn = GnsArea::Country.create(name: 'Việt Nam')
else
  vn = GnsArea::Country.find_by_name('Việt Nam')
end

if GnsArea::Country.where(name: 'Japan').empty?
  jp = GnsArea::Country.create(name: 'Japan')
else
  jp = GnsArea::Country.find_by_name('Japan')
end

puts "Total #{GnsArea::Country.count} countries in the table"

# =====================================================================================================
# Import states
xlsx_states = Roo::Spreadsheet.open('engines/gns_area/database/danh_sach_cap_tinh_2019_02_28.xlsx')
# Read excel file. sheet tabs loop
xlsx_states.each_with_pagename do |name, sheet|
  thutu_tinh = 0
  
  sheet.each_row_streaming do |row|
    if row[1].value == vn.id # kiem tra xem co phai ma quoc gia la cua Viet Nam khong (ID Viet Nam vua tao o tren)
      if GnsArea::State.where(name: "#{row[0].value}", country_id: vn.id).empty? # kiem tra xem ten tinh/thanhpho da ton tai chua /neu chua thi tao
        st = GnsArea::State.create(
          name: row[0].value,
          country_id: row[1].value
        )
        thutu_tinh += 1
      end
    end    
  end
  puts '-----'
  puts "#{thutu_tinh} states (Vietnam) have been imported"
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
  puts "#{thutu_huyen} districts (Vietnam) have been imported"
  puts "Total #{GnsArea::District.count} districts in the table"
end

# =====================================================================================================
# Import states /nhat ban
xlsx_states = Roo::Spreadsheet.open('engines/gns_area/database/danh_sach_cap_tinh_nhat_ban_2019.xlsx')
# Read excel file. sheet tabs loop
xlsx_states.each_with_pagename do |name, sheet|
  thutu_tinh = 0
  
  sheet.each_row_streaming do |row|
    if row[1].value == jp.id # kiem tra xem co phai ma quoc gia la cua Japan (Nhat Ban) khong (ID Japan vua tao o tren)
      if GnsArea::State.where(name: "#{row[0].value}", country_id: jp.id).empty? # kiem tra xem ten tinh/thanhpho da ton tai chua /neu chua thi tao
        st = GnsArea::State.create(
          name: row[0].value,
          country_id: row[1].value
        )
        thutu_tinh += 1
      end
    end    
  end
  puts '-----'
  puts "#{thutu_tinh} states (Japan) have been imported"
end

# Update cache search
GnsArea::Country.all.each do |c|
  c.update_cache_search
end
puts 'Countries: Cache search have been updated'

GnsArea::State.all.each do |s|
  s.update_cache_search
end
puts 'States: Cache search have been updated'

GnsArea::District.all.each do |d|
  d.update_cache_search
end
puts 'Districts: Cache search have been updated'