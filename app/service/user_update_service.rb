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
    add_organisation_to_user_forms if @user.trial_user_upgraded?
    add_organisation_to_user_mou if @user.given_organisation?
  end

  def add_organisation_to_user_forms
    Form.update_organisation_for_creator(@user.id, @user.organisation_id)
  end

  def add_organisation_to_user_mou
    MouSignature.add_mou_signature_organisation(@user)
  end
end
