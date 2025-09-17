module Users
  class FilterInput < BaseInput
    attr_accessor :email, :name, :organisation_id

    def has_filters?
      [email, name, organisation_id].any?(&:present?)
    end
  end
end
