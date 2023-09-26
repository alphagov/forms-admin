class UserUpgradeRequest
  include ActiveModel::Model
  include ActiveModel::Validations

  validates :met_requirements, acceptance: true
end
