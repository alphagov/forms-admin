class Domain < ApplicationRecord
  belongs_to :organisation, optional: true
end
