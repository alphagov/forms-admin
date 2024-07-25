class ReportsController < ApplicationController
  def features
    data = Report.find("features")

    render template: "reports/features", locals: { data: }
  end
end
