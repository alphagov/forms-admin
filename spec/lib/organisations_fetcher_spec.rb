require "rails_helper"

RSpec.describe OrganisationsFetcher do
  subject(:organisations_fetcher) { described_class.new }

  def stub_organisation_api_has_organisations_with_bodies(organisation_bodies)
    stub_request(:get, "https://www.gov.uk/api/organisations")
      .to_return_json(body: { results: organisation_bodies })
  end

  def organisation_details_for_slug(slug, content_id = Faker::Internet.uuid)
    {
      details: { content_id:, slug:, abbreviation: slug.titleize.split.collect(&:chr).join },
      title: slug.titleize,
    }
  end

  it "creates new organisations when none exist" do
    stub_organisation_api_has_organisations_with_bodies([
      organisation_details_for_slug("department-for-tests"),
      organisation_details_for_slug("ministry-of-tests"),
    ])

    expect {
      organisations_fetcher.call
    }.to change(Organisation, :count).by(2)

    expect(Organisation.find_by(slug: "department-for-tests")).to be_persisted
    expect(Organisation.find_by(slug: "ministry-of-tests")).to be_persisted
  end

  it "updates an existing organisation when its slug changes" do
    organisation = create :organisation, slug: "test-org", name: "Test Organisation"

    stub_organisation_api_has_organisations_with_bodies([
      organisation_details_for_slug("test-organisation", organisation.govuk_content_id),
    ])

    organisations_fetcher.call
    organisation.reload

    expect(organisation.slug).to eq "test-organisation"
  end

  it "updates an existing organisation when it is closed" do
    organisation = create :organisation, slug: "test-org"

    organisation_details = organisation_details_for_slug("test-organisation", organisation.govuk_content_id)
    organisation_details[:details][:govuk_status] = "closed"

    stub_organisation_api_has_organisations_with_bodies([
      organisation_details,
    ])

    organisations_fetcher.call
    organisation.reload

    expect(organisation.closed).to be true
  end

  it "updates an existing organisation when its abbreviation changes" do
    organisation = create :organisation, slug: "department-for-testing", abbreviation: nil

    stub_organisation_api_has_organisations_with_bodies([
      organisation_details_for_slug("department-for-testing", organisation.govuk_content_id).deep_merge({ details: { abbreviation: "DfT" } }),
    ])

    organisations_fetcher.call
    organisation.reload

    expect(organisation.abbreviation).to eq "DfT"
  end

  context "when doing a dry run" do
    let(:dry_run) { true }

    it "does not create an organisation" do
      stub_organisation_api_has_organisations_with_bodies([
        organisation_details_for_slug("department-for-tests"),
      ])

      expect(Rails.logger).to receive(:info).with(/Creating/)

      expect {
        organisations_fetcher.call(dry_run:)
      }.not_to change(Organisation, :count)
    end

    it "does not update an existing organisation" do
      organisation = create :organisation, slug: "department-for-testing", abbreviation: nil

      stub_organisation_api_has_organisations_with_bodies([
        organisation_details_for_slug("department-for-testing", organisation.govuk_content_id).deep_merge({ details: { abbreviation: "DfT" } }),
      ])

      expect(Rails.logger).to receive(:info).with(/Updating/)

      organisations_fetcher.call(dry_run:)
      organisation.reload

      expect(organisation.abbreviation).to be_nil
    end
  end
end
