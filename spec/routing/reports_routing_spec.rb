require "rails_helper"

RSpec.describe ReportsController, type: :routing do
  describe "feature reports" do
    describe "routing" do
      it "routes to#features" do
        expect(get: "/reports/features").to route_to("reports#features")
      end

      it "routes to #questions_with_answer_type" do
        expect(get: "/reports/features/questions-with-answer-type/text").to route_to("reports#questions_with_answer_type", answer_type: "text")
      end

      it "routes to #questions_with_add_another_answer" do
        expect(get: "/reports/features/questions-with-add-another-answer").to route_to("reports#questions_with_add_another_answer")
      end

      it "routes to #questions_with_add_another_answer with csv format" do
        expect(get: "/reports/features/questions-with-add-another-answer.csv").to route_to("reports#questions_with_add_another_answer", format: "csv")
      end

      it "routes to #forms_with_routes" do
        expect(get: "/reports/features/forms-with-routes").to route_to("reports#forms_with_routes")
      end

      it "routes to #forms_with_routes with csv format" do
        expect(get: "/reports/features/forms-with-routes.csv").to route_to("reports#forms_with_routes", format: "csv")
      end

      it "routes to #forms_with_payments" do
        expect(get: "/reports/features/forms-with-payments").to route_to("reports#forms_with_payments")
      end

      it "routes to #forms_with_payments with csv format" do
        expect(get: "/reports/features/forms-with-payments.csv").to route_to("reports#forms_with_payments", format: "csv")
      end

      it "routes to #forms_with_csv_submission_enabled" do
        expect(get: "/reports/features/forms-with-csv-submission-enabled").to route_to("reports#forms_with_csv_submission_enabled")
      end

      it "routes to #forms_with_csv_submission_enabled with csv format" do
        expect(get: "/reports/features/forms-with-csv-submission-enabled.csv").to route_to("reports#forms_with_csv_submission_enabled", format: "csv")
      end
    end

    describe "path helpers" do
      it "routes to #questions_with_add_another_answer as csv" do
        expect(get: report_questions_with_add_another_answer_path(format: :csv)).to route_to("reports#questions_with_add_another_answer", format: "csv")
      end

      it "routes to #forms_with_routes as csv" do
        expect(get: report_forms_with_routes_path(format: :csv)).to route_to("reports#forms_with_routes", format: "csv")
      end

      it "routes to #forms_with_payments as csv" do
        expect(get: report_forms_with_payments_path(format: :csv)).to route_to("reports#forms_with_payments", format: "csv")
      end

      it "routes to #forms_with_csv_submission_enabled as csv" do
        expect(get: report_forms_with_csv_submission_enabled_path(format: :csv)).to route_to("reports#forms_with_csv_submission_enabled", format: "csv")
      end
    end
  end
end
