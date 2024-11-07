module LastSignedInAtReportComponent
  class View < ViewComponent::Base
    def initialize(caption, users, empty_message: nil)
      @caption = caption
      @users = users
      @empty_message = empty_message

      super
    end

    def render?
      @users.present? || @empty_message.present?
    end

    def call
      if @users.present?
        govuk_table(
          rows: rows(@users),
          head:,
          caption: @caption,
          first_cell_is_header: true,
        )
      else
        tag.h(@caption, class: "govuk-heading-m") +
          tag.p(@empty_message, class: "govuk-body")
      end
    end

  private

    def head
      [
        { text: I18n.t("users.index.table_headings.name") },
        { text: I18n.t("users.index.table_headings.email") },
        { text: I18n.t("users.index.table_headings.access") },
      ]
    end

    def rows(users)
      users.order(:has_access, :name).map do |user|
        [
          { text: user.name || I18n.t("users.index.name_blank") },
          { text: user.email },
          { text: I18n.t("users.has_access.#{user.has_access}.name") },
        ]
      end
    end
  end
end
