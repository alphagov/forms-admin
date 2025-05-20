require "rails_helper"

RSpec.describe ReportsController, type: :routing do
  describe "feature reports" do
    describe "routing" do
      it "routes to#features" do
        expect(get: "/reports/features").to route_to("reports#features")
      end

      it "routes to questions_with_answer_type" do
        expect(get: "/reports/features/questions-with-answer-type/text").to route_to("reports#questions_with_answer_type", answer_type: "text")
      end

      it "routes to #feature_report with questions_with_add_another_answer" do
        expect(get: "/reports/features/questions-with-add-another-answer").to route_to("reports#feature_report", report: "questions-with-add-another-answer")
      end

      it "routes to #feature_report with questions_with_add_another_answer and csv format" do
        expect(get: "/reports/features/questions-with-add-another-answer.csv").to route_to("reports#feature_report", report: "questions-with-add-another-answer", format: "csv")
      end

      it "routes to #feature_report with forms_with_routes" do
        expect(get: "/reports/features/forms-with-routes").to route_to("reports#feature_report", report: "forms-with-routes")
      end

      it "routes to #feature_report with forms_with_routes and csv format" do
        expect(get: "/reports/features/forms-with-routes.csv").to route_to("reports#feature_report", report: "forms-with-routes", format: "csv")
      end

      it "routes to #feature_report with forms_with_payments" do
        expect(get: "/reports/features/forms-with-payments").to route_to("reports#feature_report", report: "forms-with-payments")
      end

      it "routes to #feature_report with forms_with_payments and csv format" do
        expect(get: "/reports/features/forms-with-payments.csv").to route_to("reports#feature_report", report: "forms-with-payments", format: "csv")
      end

      it "routes to #feature_report with forms_with_csv_submission_enabled" do
        expect(get: "/reports/features/forms-with-csv-submission-enabled").to route_to("reports#feature_report", report: "forms-with-csv-submission-enabled")
      end

      it "routes to #feature_report with forms_with_csv_submission_enabled and csv format" do
        expect(get: "/reports/features/forms-with-csv-submission-enabled.csv").to route_to("reports#feature_report", report: "forms-with-csv-submission-enabled", format: "csv")
      end

      it "does not route to #feature_report if param does not match defined report" do
        expect(get: "/reports/features/foobar").not_to route_to("reports#feature_report", report: "foobar")
      end
    end

    describe "path helpers" do
      it "routes to #questions_with_add_another_answer as csv" do
        expect(get: feature_report_path(report: "questions-with-add-another-answer", format: :csv)).to route_to("reports#feature_report", report: "questions-with-add-another-answer", format: "csv")
      end

      it "routes to #forms_with_routes as csv" do
        expect(get: feature_report_path(report: "forms-with-routes", format: :csv)).to route_to("reports#feature_report", report: "forms-with-routes", format: "csv")
      end

      it "routes to #forms_with_payments as csv" do
        expect(get: feature_report_path(report: "forms-with-payments", format: :csv)).to route_to("reports#feature_report", report: "forms-with-payments", format: "csv")
      end

      it "routes to #forms_with_csv_submission_enabled as csv" do
        expect(get: feature_report_path(report: "forms-with-csv-submission-enabled", format: :csv)).to route_to("reports#feature_report", report: "forms-with-csv-submission-enabled", format: "csv")
      end
    end
  end
end
