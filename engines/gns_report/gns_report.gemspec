$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "gns_report/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "gns_report"
  spec.version     = GnsReport::VERSION
  spec.authors     = ["Ton Hung Nguyen"]
  spec.email       = ["tonhungstar@gmail.com"]
  spec.homepage    = "http://globalnaturesoft.com"
  spec.summary     = "Report features of GNS."
  spec.description = "Report features of GNS."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 5.2.3"

  spec.add_development_dependency "pg"
end
