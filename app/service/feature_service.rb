class FeatureService
  class << self
    def enabled?(feature_name)
      return false if Settings.features.blank?

      segments = feature_name.to_s.split(".")
      segments.reduce(Settings.features) { |config, segment| config[segment] }
    end
  end
end
