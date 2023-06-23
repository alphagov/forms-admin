module HostingEnvironment
  def self.environment_name
    ENV.fetch("PAAS_ENVIRONMENT", "unknown-environment")
  end

  def self.friendly_environment_name
    key = local_development? ? "local" : environment_name

    I18n.t("environment_names.#{key}", default: key)
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
