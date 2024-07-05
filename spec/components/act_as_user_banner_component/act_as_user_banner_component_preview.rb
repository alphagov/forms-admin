class ActAsUserBannerComponent::ActAsUserBannerComponentPreview < ViewComponent::Preview
  def default
    original_user = FactoryBot.build :super_admin_user
    acting_as = FactoryBot.build :user
    render(ActAsUserBannerComponent::View.new(acting_as, original_user))
  end
end
