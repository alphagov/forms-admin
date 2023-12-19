class Domain < ActiveYaml::Base
  include ActiveHash::Associations

  set_root_path "../forms-deploy/config/data"

  belongs_to :organisation, foreign_key: :govuk_content_id, primary_key: :govuk_content_id
end
