time = Time.now.strftime("%m") + Time.now.strftime("%Y").last(2)

GnsProject::Project.create(
  code: "PRJ-#{time + 1.to_s.rjust(3, '0')}",
  name: "Công trình nhà phố Ny'Ah",
  category_id: 1
) if GnsProject::Project.where(name: "Công trình nhà phố Ny'Ah").empty?

GnsProject::Project.create(
  code: "PRJ-#{time + 2.to_s.rjust(3, '0')}",
  name: "Academy AEC Center",
  category_id: 1
) if GnsProject::Project.where(name: "Academy AEC Center").empty?

GnsProject::Project.create(
  code: "PRJ-#{time + 3.to_s.rjust(3, '0')}",
  name: "Nhà máy Mercedes",
  category_id: 1
) if GnsProject::Project.where(name: "Nhà máy Mercedes").empty?

GnsProject::Project.create(
  code: "PRJ-#{time + 4.to_s.rjust(3, '0')}",
  name: "Khách sạn Côn Đảo",
  category_id: 1
) if GnsProject::Project.where(name: "Khách sạn Côn Đảo").empty?

GnsProject::Project.create(
  code: "PRJ-#{time + 5.to_s.rjust(3, '0')}",
  name: "Văn phòng Công ty Alpes",
  category_id: 1
) if GnsProject::Project.where(name: "Văn phòng Công ty Alpes").empty?

GnsProject::Project.create(
  code: "PRJ-#{time + 6.to_s.rjust(3, '0')}",
  name: "Tòa nhà VP TM DV Becamex",
  category_id: 1
) if GnsProject::Project.where(name: "Tòa nhà VP TM DV Becamex").empty?

GnsProject::Project.create(
  code: "PRJ-#{time + 7.to_s.rjust(3, '0')}",
  name: "Công trình nhà phố Đà Nẵng",
  category_id: 1
) if GnsProject::Project.where(name: "Công trình nhà phố Đà Nẵng").empty?

GnsProject::Project.create(
  code: "PRJ-#{time + 8.to_s.rjust(3, '0')}",
  name: "Nhà máy Ruby - Myanmar",
  category_id: 1
) if GnsProject::Project.where(name: "Nhà máy Ruby - Myanmar").empty?

GnsProject::Project.create(
  code: "PRJ-#{time + 9.to_s.rjust(3, '0')}",
  name: "Nhà máy Heineken - Phnôm Pênh",
  category_id: 1
) if GnsProject::Project.where(name: "Nhà máy Heineken - Phnôm Pênh").empty?

GnsProject::Project.create(
  code: "PRJ-#{time + 10.to_s.rjust(3, '0')}",
  name: "Văn phòng Lý Bảo Minh",
  category_id: 1
) if GnsProject::Project.where(name: "Văn phòng Lý Bảo Minh").empty?