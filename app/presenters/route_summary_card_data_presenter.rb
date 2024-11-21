class RouteSummaryCardDataPresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include GovukRailsCompatibleLinkHelper

  attr_reader :form, :page, :pages

  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(form:, page:, pages:)
    @page = page
    @pages = pages
    @form = form
  end

  def summary_card_data
    conditional_cards = conditional_route_cards
    conditional_cards + [default_route_card(conditional_cards.length + 1)]
  end

  def all_routes
    all_form_routing_conditions = pages.flat_map(&:conditions).compact_blank
    all_form_routing_conditions.select { |rc| rc.check_page_id == page.id }
  end

  def conditional_routes
    all_routes.select { |rc| rc.answer_value.present? }
  end

private

  def conditional_route_cards
    conditional_routes.map.with_index(1) { |routing_condition, index| conditional_route_card(routing_condition, index) }
  end

  def conditional_route_card(routing_condition, index)
    goto_page_name = routing_condition.skip_to_end ? end_page_name : page_name(routing_condition.goto_page_id)

    {
      card: {
        title: I18n.t("page_route_card.route_title", index:),
        classes: "app-summary-card",
        actions: [
          govuk_link_to(I18n.t("page_route_card.edit"), edit_condition_path(form_id: form.id, page_id: page.id, condition_id: routing_condition.id)),
        ],
      },
      rows: [
        {
          key: { text: I18n.t("page_route_card.if_answer_is") },
          value: { text: I18n.t("page_route_card.conditional_answer_value", answer_value: routing_condition.answer_value) },
        },
        {
          key: { text: I18n.t("page_route_card.take_the_person_to") },
          value: { text: goto_page_name },
        },
      ],
    }
  end

  def default_route_card(index)
    continue_to_name = page.has_next_page? ? page_name(page.next_page) : end_page_name

    {
      card: {
        title: I18n.t("page_route_card.route_title", index:),
        classes: "app-summary-card",
        actions: [
          edit_secondary_skip_link,
        ],
      },
      rows: [
        {
          key: { text: I18n.t("page_route_card.continue_to") },
          value: { text: continue_to_name },
        },
        *secondary_skip_rows,
      ],
    }
  end

  def edit_secondary_skip_link
    if FeatureService.enabled?(:branch_routing) && all_routes.find(&:secondary_skip?).present?
      govuk_link_to(I18n.t("page_route_card.edit"), edit_secondary_skip_path(form_id: form.id, page_id: page.id))
    end
  end

  def secondary_skip_rows
    secondary_skip = all_routes.find(&:secondary_skip?)

    if secondary_skip.blank?
      if FeatureService.enabled?(:branch_routing)
        return [
          {
            key: { text: I18n.t("page_route_card.then") },
            value: { text: govuk_link_to(I18n.t("page_route_card.set_secondary_skip"), new_secondary_skip_path(form_id: form.id, page_id: page.id)) },
          },
        ]
      else
        return []
      end
    end

    goto_page_name = secondary_skip.skip_to_end ? end_page_name : page_name(secondary_skip.goto_page_id)
    routing_page_name = page_name(secondary_skip.routing_page_id)

    [
      {
        key: { text: I18n.t("page_route_card.secondary_skip_after") },
        value: { text: routing_page_name },
      },
      {
        key: { text: I18n.t("page_route_card.secondary_skip_then") },
        value: { text: goto_page_name },
      },
    ]
  end

  def page_name(page_id)
    target_page = pages.find { |page| page.id == page_id }

    page_name = target_page.question_text
    page_position = target_page.position

    I18n.t("page_route_card.page_name", page_position:, page_name:)
  end

  def end_page_name
    I18n.t("page_route_card.check_your_answers")
  end
end
