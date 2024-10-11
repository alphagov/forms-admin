class FeatureService
  class UserRequiredError < StandardError; end

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
    feature = Settings.features.dig(*segments)

    return feature unless feature.is_a? Config::Options

    if feature.organisations.present?
      raise UserRequiredError, "Feature #{feature_name} requires user to be provided" if @user.blank?

      if @user.organisation.present?
        organisation_key = @user.organisation.slug.underscore.to_sym
        return feature.organisations[organisation_key] if feature.organisations.key?(organisation_key)
      end
    end

    feature.enabled
  end
end
