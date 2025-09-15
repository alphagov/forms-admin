module HostPatterns
  ALLOWED_HOST_PATTERNS = [
    /admin\.forms\.service\.gov\.uk/,
    /admin\.[^.]*\.forms\.service\.gov\.uk/,
    /admin\.internal.[^.]*\.forms\.service\.gov\.uk/,
    /pr-[^.]*\.admin\.review\.forms\.service\.gov\.uk/,
    /pr-[^.]*-admin\.submit\.review\.forms\.service\.gov\.uk/,
  ].freeze
end
