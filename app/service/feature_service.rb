class FeatureService
  attr_reader :user

  class << self
    def enabled?(...)
      FeatureService.new(nil).enabled?(...)
    end
  end

  def initialize(user)
    @user = user
  end

  def enabled?(feature_name)
    return false if Settings.features.blank?

    segments = feature_name.to_s.split(".")
    feature_config = Settings.features.dig(*segments)

    if feature_config.is_a? Config::Options
      enabled = feature_config.key?(:enabled) ? feature_config.enabled : false
      enabled = feature_config.trial_users if feature_config.key?(:trial_users) && user.trial?

      if feature_config.organisations.present? && !user.trial?
        organisation_key = user.organisation.slug.underscore.to_sym
        enabled = feature_config.organisations[organisation_key] if feature_config.organisations.key?(organisation_key)
      end

      enabled
    else
      feature_config
    end
  end
end
