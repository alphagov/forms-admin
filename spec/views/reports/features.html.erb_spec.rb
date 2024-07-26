require "rails_helper"

describe "users/edit.html.erb" do
  let(:report) do
    Report.new({ total_live_forms: 3,
                 live_forms_with_answer_type: { address: 1,
                                                date: 1,
                                                email: 1,
                                                name: 1,
                                                national_insurance_number: 1,
                                                number: 1,
                                                organisation_name: 1,
                                                phone_number: 1,
                                                selection: 3,
                                                text: 3 },
                 live_pages_with_answer_type: { address: 1,
                                                date: 1,
                                                email: 1,
                                                name: 1,
                                                national_insurance_number: 1,
                                                number: 1,
                                                organisation_name: 2,
                                                phone_number: 1,
                                                selection: 4,
                                                text: 5 },
                 live_forms_with_payment: 1,
                 live_forms_with_routing: 2 })
  end

  before do
    render template: "reports/features", locals: { data: report }
  end

  describe "page title" do
    it "matches the heading" do
      expect(view.content_for(:title)).to eq "Feature usage on live forms"
    end
  end

  it "contains page heading" do
    expect(rendered).to have_css("h1.govuk-heading-l", text: "Feature usage on live forms")
  end

  it "includes the number of total live forms" do
    expect(response.body).to include "Total live forms: #{report.total_live_forms}"
  end

  Page::ANSWER_TYPES.map(&:to_sym).each do |answer_type|
    it "contains a heading for #{answer_type}" do
      expect(rendered).to have_css("h3.govuk-heading-s", text: answer_type)
    end

    it "includes the number of live forms with #{answer_type}" do
      expect(response.body).to include "Number of forms which ask for this answer type: #{report.live_forms_with_answer_type.attributes[answer_type]}"
    end

    it "includes the number of live pages with #{answer_type}" do
      expect(response.body).to include "Number of pages of this answer type: #{report.live_pages_with_answer_type.attributes[answer_type]}"
    end
  end

  it "includes the number of live forms with routes" do
    expect(response.body).to include "Live forms with routes: #{report.live_forms_with_routing}"
  end

  it "includes the number of live forms with payments" do
    expect(response.body).to include "Live forms with payments: #{report.live_forms_with_payment}"
  end
end
