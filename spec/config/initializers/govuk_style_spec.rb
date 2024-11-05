require "rails_helper"

RSpec.describe "config/initializers/govuk_style.rb" do
  it "adds a date format matching GOV.UK style" do
    expect(Date.new(2017, 6, 4).to_fs(:govuk)).to eq "4 June 2017"
  end

  it "changes the default date format to GOV.UK style" do
    expect(Date.new(2017, 6, 4).to_fs).to eq "4 June 2017"
  end

  it "adds a short date format matching GOV.UK style without a year" do
    expect(Date.new(2017, 6, 4).to_fs(:govuk_short)).to eq "4 June"
  end

  it "changes the short date format to GOV.UK style" do
    expect(Date.new(2017, 6, 4).to_fs(:short)).to eq "4 June"
  end
end
