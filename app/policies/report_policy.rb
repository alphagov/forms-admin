class ReportPolicy < ApplicationPolicy
  def can_view_reports?
    user.super_admin?
  end
end
