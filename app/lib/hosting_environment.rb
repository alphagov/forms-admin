module HostingEnvironment
  def self.environment_name
    Settings.forms_env
  end

  def self.friendly_environment_name
    I18n.t("environment_names.#{environment_name}", default: environment_name)
  end

  def self.local_development?
    environment_name == "local"
  end

  def self.dev?
    environment_name == "dev"
  end

  def self.test_environment?
    dev? || local_development?
  end
end
