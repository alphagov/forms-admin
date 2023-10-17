class NavigationItemsService
  NavigationItem = Struct.new(:text, :href, :active, :classes)

  include Rails.application.routes.url_helpers

  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(user:)
    @user = user
  end

  def navigation_items
    return [] if user.blank?

    navigation_items = []
    navigation_items << NavigationItem.new(text: I18n.t("header.mous"), href: mou_signatures_path, active: false) if should_show_mous_link?
    navigation_items << NavigationItem.new(text: I18n.t("header.users"), href: users_path, active: false) if should_show_user_profile_link?
    navigation_items << NavigationItem.new(text: user.name, href: user_profile_url, active: false) if user.name.present?
    navigation_items << NavigationItem.new(text: I18n.t("header.sign_out"), href: signout_url, active: false) if signout_url.present?

    navigation_items
  end

private

  attr_reader :user

  def user_provider
    user&.provider&.to_sym
  end

  def signout_url
    if user_provider == :gds
      gds_sign_out_path
    elsif %i[auth0 cddo_sso mock_gds_sso].include? user_provider
      sign_out_path
    end
  end

  def user_profile_url
    case user_provider
    when :cddo_sso
      "https://sso.service.security.gov.uk/profile"
    when :gds
      GDS::SSO::Config.oauth_root_url
    end
  end

  def should_show_user_profile_link?
    Pundit.policy(user, :user)&.can_manage_user?
  end

  def should_show_mous_link?
    Pundit.policy(user, :mou_signature)&.can_manage_mous?
  end
end
