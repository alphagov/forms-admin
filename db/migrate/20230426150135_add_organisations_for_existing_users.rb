class AddOrganisationsForExistingUsers < ActiveRecord::Migration[7.0]
  def up
    Organisation.create!(content_id: "af07d5a5-df63-4ddc-9383-6a666845ebe9", slug: "government-digital-service", name: "Government Digital Service")

    # For each user created by gds-sso create a record in organisation table,
    # getting the data from the GOV.UK organisations API
    User.where.not(organisation_content_id: nil).select(:organisation_content_id, :organisation_slug).distinct.each do |user|
      next if Organisation.find_by(content_id: user.organisation_content_id)

      organisation_json = JSON.parse(Net::HTTP.get(URI("https://www.gov.uk/api/organisations/#{user.organisation_slug}")))

      Organisation.create!(
        content_id: organisation_json["details"]["content_id"],
        slug: organisation_json["details"]["slug"],
        name: organisation_json["title"],
      )
    end
  end

  def down
    Organisation.delete_all
  end
end
