# Create default admin user for developing
puts "Create default admin user"
GnsCore::User.create(
  email: "admin@sao-ee.vn",
  password: "aA456321@"
) if GnsCore::User.where(email: "admin@sao-ee.vn").empty?