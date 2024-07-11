require "evil_seed"

EvilSeed.configure do |config|
  config.root("Organisation") do |root|
    root.exclude(/.*/)
  end

  config.root("User") do |root|
    root.exclude(/.*/)
  end

  config.anonymize("User") do
    name { Faker::Name.name }
    email { |real_email| Faker::Internet.email(name: Faker::Number.number(digits: 10).to_s, domain: real_email.split("@").last) }
    uid { |real_uid| Digest::MD5.hexdigest(real_uid) }
    provider { "evil-seed" }
  end

  config.root("MouSignature")

  config.root("Group") do |root|
    root.exclude(/.*/)
  end

  config.root("Membership")
  config.root("GroupForm")

  config.verbose = true
end
