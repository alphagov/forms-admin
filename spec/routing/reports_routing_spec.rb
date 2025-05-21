require "rails_helper"

RSpec.describe ReportsController, type: :routing do
  describe "feature reports" do
    describe "routing" do
      %w[draft live].each do |tag|
        context "with #{tag} tag" do
          it "routes to#features for #{tag} forms" do
            expect(get: "/reports/features/#{tag}").to route_to("reports#features", tag:)
          end
        end
      end

      it "routes to questions_with_answer_type for draft forms" do
        expect(get: "/reports/features/draft/questions-with-answer-type/text").to route_to("reports#questions_with_answer_type", answer_type: "text", tag: "draft")
      end

      it "routes to questions_with_answer_type for live forms" do
        expect(get: "/reports/features/live/questions-with-answer-type/text").to route_to("reports#questions_with_answer_type", answer_type: "text", tag: "live")
      end

      it "does not route to questions_with_answer_type for invalid tag" do
        expect(get: "/reports/features/foo/questions-with-answer-type/text").not_to route_to("reports#questions_with_answer_type", answer_type: "text", tag: "foo")
      end

      %w[draft live].each do |tag|
        context "with #{tag} tag" do
          it "routes to #feature_report with questions_with_add_another_answer for #{tag} forms" do
            expect(get: "/reports/features/#{tag}/questions-with-add-another-answer").to route_to("reports#feature_report", report: "questions-with-add-another-answer", tag:)
          end

          it "routes to #feature_report with questions_with_add_another_answer for #{tag} and csv format" do
            expect(get: "/reports/features/#{tag}/questions-with-add-another-answer.csv").to route_to("reports#feature_report", report: "questions-with-add-another-answer", tag:, format: "csv")
          end

          it "routes to #feature_report with forms_with_routes for #{tag} forms" do
            expect(get: "/reports/features/#{tag}/forms-with-routes").to route_to("reports#feature_report", report: "forms-with-routes", tag:)
          end

          it "routes to #feature_report with forms_with_routes for #{tag} forms and csv format" do
            expect(get: "/reports/features/#{tag}/forms-with-routes.csv").to route_to("reports#feature_report", report: "forms-with-routes", tag:, format: "csv")
          end

          it "routes to #feature_report with forms_with_payments for #{tag} forms" do
            expect(get: "/reports/features/#{tag}/forms-with-payments").to route_to("reports#feature_report", report: "forms-with-payments", tag:)
          end

          it "routes to #feature_report with forms_with_payments for #{tag} forms and csv format" do
            expect(get: "/reports/features/#{tag}/forms-with-payments.csv").to route_to("reports#feature_report", report: "forms-with-payments", tag:, format: "csv")
          end

          it "routes to #feature_report with forms_with_csv_submission_enabled for #{tag} forms" do
            expect(get: "/reports/features/#{tag}/forms-with-csv-submission-enabled").to route_to("reports#feature_report", report: "forms-with-csv-submission-enabled", tag:)
          end

          it "routes to #feature_report with forms_with_csv_submission_enabled for #{tag} forms and csv format" do
            expect(get: "/reports/features/#{tag}/forms-with-csv-submission-enabled.csv").to route_to("reports#feature_report", report: "forms-with-csv-submission-enabled", tag:, format: "csv")
          end
        end

        it "does not route to #feature_report if param does not match defined report" do
          expect(get: "/reports/features/foobar").not_to route_to("reports#feature_report", report: "foobar")
        end
      end
    end

    describe "path helpers" do
      it "routes to #questions_with_add_another_answer for live forms as csv" do
        expect(get: feature_report_path(report: "questions-with-add-another-answer", tag: :live, format: :csv)).to route_to("reports#feature_report", report: "questions-with-add-another-answer", tag: "live", format: "csv")
      end

      it "routes to #forms_with_routes for live forms as csv" do
        expect(get: feature_report_path(report: "forms-with-routes", tag: :live, format: :csv)).to route_to("reports#feature_report", report: "forms-with-routes", tag: "live", format: "csv")
      end

      it "routes to #forms_with_payments for live forms as csv" do
        expect(get: feature_report_path(report: "forms-with-payments", tag: :live, format: :csv)).to route_to("reports#feature_report", report: "forms-with-payments", tag: "live", format: "csv")
      end

      it "routes to #forms_with_csv_submission_enabled for live forms as csv" do
        expect(get: feature_report_path(report: "forms-with-csv-submission-enabled", tag: :live, format: :csv)).to route_to("reports#feature_report", report: "forms-with-csv-submission-enabled", tag: "live", format: "csv")
      end
    end
  end
end
