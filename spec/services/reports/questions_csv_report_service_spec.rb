require "rails_helper"

RSpec.describe Reports::QuestionsCsvReportService do
  subject(:csv_reports_service) do
    described_class.new(question_page_documents)
  end

  let(:question_page_documents) { Reports::FeatureReportService.new(form_documents).questions }
  let(:form_documents) { JSON.parse(file_fixture("form_documents_response.json").read) }

  let(:group) { create(:group) }

  before do
    GroupForm.create!(form_id: 1, group:)
    GroupForm.create!(form_id: 2, group:)
    GroupForm.create!(form_id: 3, group:)
    GroupForm.create!(form_id: 4, group:)
  end

  describe "#csv" do
    it "returns a CSV with a header row and a rows for each question" do
      csv = csv_reports_service.csv
      rows = CSV.parse(csv)
      expect(rows.length).to eq 18
    end

    it "has expected values for text question" do
      csv = csv_reports_service.csv
      rows = CSV.parse(csv)
      text_question_row = rows.detect { |row| row.include? "Single line of text" }
      expect(text_question_row).to eq([
        "1",
        "live",
        "All question types form",
        group.organisation.name,
        group.organisation.id.to_s,
        group.name,
        group.external_id,
        "1",
        "Single line of text",
        "text",
        nil,
        nil,
        nil,
        "false",
        "true",
        "false",
        "single_line",
        nil,
        nil,
        nil,
        "{\"input_type\" => \"single_line\"}",
      ])
    end

    it "has expected values for selection question" do
      csv = csv_reports_service.csv
      rows = CSV.parse(csv)
      selection_question_row = rows.detect { |row| row.include? "Selection from a list of options" }
      expect(selection_question_row).to eq([
        "1",
        "live",
        "All question types form",
        group.organisation.name,
        group.organisation.id.to_s,
        group.name,
        group.external_id,
        "8",
        "Selection from a list of options",
        "selection",
        nil,
        nil,
        nil,
        "true",
        "false",
        "false",
        nil,
        "false",
        "3",
        nil,
        "{\"only_one_option\" => \"0\", \"selection_options\" => [{\"name\" => \"Option 1\"}, {\"name\" => \"Option 2\"}, {\"name\" => \"Option 3\"}]}",
      ])
    end

    it "has expected values for name question" do
      csv = csv_reports_service.csv
      rows = CSV.parse(csv)
      name_question_row = rows.detect { |row| row.include? "What’s your name?" }
      expect(name_question_row).to eq([
        "3",
        "live",
        "Branch route form",
        group.organisation.name,
        group.organisation.id.to_s,
        group.name,
        group.external_id,
        "2",
        "What’s your name?",
        "name",
        nil,
        nil,
        nil,
        "false",
        "false",
        "false",
        "full_name",
        nil,
        nil,
        "false",
        "{\"input_type\" => \"full_name\", \"title_needed\" => false}",
      ])
    end

    it "has expected values for question with routing conditions" do
      csv = csv_reports_service.csv
      rows = CSV.parse(csv)
      routing_question_row = rows.detect { |row| row.include? "How many times have you filled out this form?" }
      expect(routing_question_row).to eq([
        "3",
        "live",
        "Branch route form",
        group.organisation.name,
        group.organisation.id.to_s,
        group.name,
        group.external_id,
        "1",
        "How many times have you filled out this form?",
        "selection",
        nil,
        nil,
        nil,
        "false",
        "false",
        "true",
        nil,
        "true",
        "2",
        nil,
        "{\"only_one_option\" => \"true\", \"selection_options\" => [{\"name\" => \"Once\"}, {\"name\" => \"More than once\"}]}",
      ])
    end
  end
end
