require "evil_seed"

EvilSeed.configure do |config|
  config.root("User") do |root|
    root.exclude("forms")

    root.exclude("versions")
  end

  config.root("Group")

  config.root("GroupForm")

  config.verbose = true
end
