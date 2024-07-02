class UserUpdateService
  def initialize(user, params)
    @user = user
    @params = params
  end

  def update_user
    updated = @user.update(@params)
    on_user_update if updated
    updated
  end

private

  def on_user_update
    add_organisation_to_user_mou if @user.given_organisation?
    update_user_memberships
  end

  def add_organisation_to_user_mou
    MouSignature.add_mou_signature_organisation(@user)
  end

  def update_user_memberships
    Membership.destroy_invalid_organisation_memberships(@user)
  end
end
