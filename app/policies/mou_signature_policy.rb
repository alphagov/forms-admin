class MouSignaturePolicy < ApplicationPolicy
  def can_manage_mous?
    user.super_admin?
  end
end
