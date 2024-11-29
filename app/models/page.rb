class Page
  ANSWER_TYPES_EXCLUDING_FILE = %w[name organisation_name email phone_number national_insurance_number address date selection number text].freeze
  ANSWER_TYPES_INCLUDING_FILE = (ANSWER_TYPES_EXCLUDING_FILE + %w[file]).freeze

  ANSWER_TYPES_WITHOUT_SETTINGS = %w[organisation_name email phone_number national_insurance_number number].freeze

  ANSWER_TYPES_WITH_SETTINGS = %w[selection text date address name].freeze
end
