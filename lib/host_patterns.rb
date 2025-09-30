module HostPatterns
  DEFAULT_HOST_PATTERNS = [
    /admin\.forms\.service\.gov\.uk/,
    /admin\.[^.]*\.forms\.service\.gov\.uk/,
    /admin\.internal.[^.]*\.forms\.service\.gov\.uk/,
    /pr-[^.]*\.admin\.review\.forms\.service\.gov\.uk/,
    /pr-[^.]*-admin\.submit\.review\.forms\.service\.gov\.uk/,
  ].freeze

  def self.allowed_host_patterns
    additional_patterns = ENV.fetch("ALLOWED_HOST_PATTERNS", "").split(",").map { |pattern| Regexp.new(pattern.strip) }

    [*DEFAULT_HOST_PATTERNS, *additional_patterns]
  end
end
