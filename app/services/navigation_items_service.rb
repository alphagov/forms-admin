class NavigationItemsService
  NavigationItem = Struct.new(:text, :href, :active, :classes) do
    def initialize(text:, href:, active:, classes: [])
      super(text, href, active, classes)
    end
  end

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

    navigation_items = [
      mou_navigation_item,
      users_navigation_item,
      reports_navigation_item,
      support_navigation_item,
      profile_navigation_item,
      signout_navigation_item,
    ]

    navigation_items.compact_blank
  end

private

  attr_reader :user

  def mou_navigation_item
    return nil unless should_show_mous_link?

    NavigationItem.new(text: I18n.t("header.mous"), href: mou_signatures_path, active: false)
  end

  def users_navigation_item
    return nil unless should_show_user_profile_link?

    NavigationItem.new(text: I18n.t("header.users"), href: users_path, active: false)
  end

  def reports_navigation_item
    return nil unless should_show_reports_link?

    NavigationItem.new(text: I18n.t("header.reports"), href: reports_path, active: false)
  end

  def support_navigation_item
    return nil if Settings.forms_product_page.support_url.blank?

    NavigationItem.new(text: I18n.t("header.support"), href: Settings.forms_product_page.support_url, active: false)
  end

  def profile_navigation_item
    return nil if user.name.blank?

    NavigationItem.new(text: user.name, href: user_profile_url, active: false)
  end

  def signout_navigation_item
    return nil if signout_url.blank?

    NavigationItem.new(text: I18n.t("header.sign_out"), href: signout_url, active: false)
  end

  def user_provider
    user.provider.to_sym
  end

  def signout_url
    if user_provider == :gds
      gds_sign_out_path
    elsif %i[auth0 developer mock_gds_sso user_research].include? user_provider
      sign_out_path
    end
  end

  def user_profile_url
    if user_provider == :gds
      GDS::SSO::Config.oauth_root_url
    end
  end

  def should_show_user_profile_link?
    Pundit.policy(user, :user).can_manage_user?
  end

  def should_show_mous_link?
    Pundit.policy(user, :mou_signature).can_manage_mous?
  end

  def should_show_reports_link?
    Pundit.policy(user, :report).can_view_reports?
  end
end
