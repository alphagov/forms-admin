class RouteSummaryCardDataPresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include GovukRailsCompatibleLinkHelper

  attr_reader :form, :pages, :page, :routes

  def initialize(form:, pages:, page:, routes:)
    @form = form
    @pages = pages
    @page = page
    @routes = routes
  end

  def summary_card_data
    cards = conditional_route_cards
    cards << secondary_skip_card if secondary_skip
    cards
  end

private

  def secondary_skip
    @secondary_skip ||= routes.find(&:secondary_skip?)
  end

  def conditional_routes
    routes.select { |rc| rc.answer_value.present? }
  end

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

  def secondary_skip_card
    continue_to_name = page.has_next_page? ? page_name(page.next_page) : end_page_name

    actions = if FeatureService.new(group: form.group).enabled?(:branch_routing) && secondary_skip
                [
                  edit_secondary_skip_link,
                  delete_secondary_skip_link,
                ]
    else
                []
    end

    {
      card: {
        title: I18n.t("page_route_card.any_other_answer"),
        classes: "app-summary-card",
        actions:,
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
    govuk_link_to(I18n.t("page_route_card.edit"), edit_secondary_skip_path(form_id: form.id, page_id: page.id))
  end

  def delete_secondary_skip_link
    govuk_link_to(I18n.t("page_route_card.delete"), delete_secondary_skip_path(form_id: form.id, page_id: page.id))
  end

  def secondary_skip_rows
    unless secondary_skip
      if FeatureService.new(group: form.group).enabled?(:branch_routing)
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

    if target_page.present?
      page_name = target_page.question_text
      page_position = target_page.position

      I18n.t("page_route_card.page_name", page_position:, page_name:)
    else
      I18n.t("page_route_card.page_name_not_exist")
    end
  end

  def end_page_name
    I18n.t("page_route_card.check_your_answers")
  end
end
