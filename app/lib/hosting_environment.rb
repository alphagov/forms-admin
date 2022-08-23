module HostingEnvironment
  def self.environment_name
    ENV.fetch("PAAS_ENVIRONMENT", "unknown-environment")
  end

  def self.local_development?
    environment_name == "unknown-environment" && !Rails.env.production?
  end

  def self.dev?
    environment_name == "dev"
  end

  def self.test_environment?
    dev? || local_development?
  end
end
