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

      it "routes to #live_questions_with_add_another_answer_csv" do
        expect(get: "/reports/features/questions-with-add-another-answer.csv").to route_to("reports#live_questions_with_add_another_answer_csv")
      end

      it "routes to #forms_with_routes" do
        expect(get: "/reports/features/forms-with-routes").to route_to("reports#forms_with_routes")
      end

      it "routes to #live_forms_with_routes_csv" do
        expect(get: "/reports/features/forms-with-routes.csv").to route_to("reports#live_forms_with_routes_csv")
      end

      it "routes to #forms_with_payments" do
        expect(get: "/reports/features/forms-with-payments").to route_to("reports#forms_with_payments")
      end

      it "routes to #live_forms_with_payments_csv" do
        expect(get: "/reports/features/forms-with-payments.csv").to route_to("reports#live_forms_with_payments_csv")
      end

      it "routes to #forms_with_csv_submission_enabled" do
        expect(get: "/reports/features/forms-with-csv-submission-enabled").to route_to("reports#forms_with_csv_submission_enabled")
      end

      it "routes to #live_forms_with_csv_submission_enabled_csv" do
        expect(get: "/reports/features/forms-with-csv-submission-enabled.csv").to route_to("reports#live_forms_with_csv_submission_enabled_csv")
      end
    end

    describe "path helpers" do
      it "routes to #live_questions_with_add_another_answer_csv" do
        expect(get: report_live_questions_with_add_another_answer_csv_path).to route_to("reports#live_questions_with_add_another_answer_csv")
      end

      it "routes to #live_forms_with_routes_csv" do
        expect(get: report_live_forms_with_routes_csv_path).to route_to("reports#live_forms_with_routes_csv")
      end

      it "routes to #live_forms_with_payments_csv" do
        expect(get: report_live_forms_with_payments_csv_path).to route_to("reports#live_forms_with_payments_csv")
      end

      it "routes to #live_forms_with_csv_submission_enabled_csv" do
        expect(get: report_live_forms_with_csv_submission_enabled_csv_path).to route_to("reports#live_forms_with_csv_submission_enabled_csv")
      end
    end
  end
end
