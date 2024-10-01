require "rails_helper"

describe "reports/features.html.erb" do
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
                 live_forms_with_routing: 2,
                 live_forms_with_add_another_answer: 3 })
  end

  before do
    render template: "reports/features", locals: { data: report }
  end

  describe "page title" do
    it "matches the heading" do
      expect(view.content_for(:title)).to eq "Feature usage on live forms"
    end
  end

  it "has a back link to the live form page" do
    expect(view.content_for(:back_link)).to have_link("Back to reports", href: reports_path)
  end

  it "contains page heading" do
    expect(rendered).to have_css("h1.govuk-heading-l", text: "Feature usage on live forms")
  end

  it "includes the number of total live forms" do
    expect(rendered).to have_css(".govuk-summary-list__row", text: "Total live forms#{report.total_live_forms}")
  end

  Page::ANSWER_TYPES.map(&:to_sym).each do |answer_type|
    it "contains a heading for #{answer_type}" do
      expect(rendered).to have_css("th", text: I18n.t("helpers.label.page.answer_type_options.names.#{answer_type}"))
    end

    it "includes the number of live forms with #{answer_type}" do
      expect(rendered).to have_css("[data-live-forms-with-answer-type-#{answer_type.to_s.dasherize}]", text: report.live_forms_with_answer_type.attributes[answer_type].to_s)
    end

    it "includes the number of live pages with #{answer_type}" do
      expect(rendered).to have_css("[data-live-pages-with-answer-type-#{answer_type.to_s.dasherize}]", text: report.live_pages_with_answer_type.attributes[answer_type].to_s)
    end
  end

  context "when an answer type is missing from the data" do
    let(:report) do
      Report.new({ total_live_forms: 3,
                   live_forms_with_answer_type: { address: 1 },
                   live_pages_with_answer_type: { address: 1 },
                   live_forms_with_payment: 1,
                   live_forms_with_routing: 2,
                   live_forms_with_add_another_answer: 3 })
    end

    it "displays 0 for live_forms_with_answer_type" do
      expect(rendered).to have_css("[data-live-forms-with-answer-type-number]", text: "0")
    end

    it "displays 0 for live_pages_with_answer_type" do
      expect(rendered).to have_css("[data-live-pages-with-answer-type-number]", text: "0")
    end
  end

  it "includes the number of live forms with routes" do
    expect(rendered).to have_css(".govuk-summary-list__row", text: "Live forms with routes#{report.live_forms_with_routing}")
  end

  it "includes the number of live forms with payments" do
    expect(rendered).to have_css(".govuk-summary-list__row", text: "Live forms with payments#{report.live_forms_with_payment}")
  end

  it "includes the number of live forms with add another answer" do
    expect(rendered).to have_css(".govuk-summary-list__row", text: "Live forms with add another answer#{report.live_forms_with_add_another_answer}")
  end
end
