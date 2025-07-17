class Condition < ApplicationRecord
  belongs_to :routing_page, class_name: "Page"
  belongs_to :check_page, class_name: "Page", optional: true
  belongs_to :goto_page, class_name: "Page", optional: true

  has_one :form, through: :routing_page

  before_destroy :destroy_postconditions

  def save_and_update_form
    save!
    # TODO: https://trello.com/c/dg9CFPgp/1503-user-triggers-state-change-from-live-to-livewithdraft
    # Will not be needed when users can trigger this event themselves through the UI
    form.create_draft_from_live_form if form.live?
    form.update!(question_section_completed: false)
  end

  def destroy_and_update_form!
    destroy! && form.update!(question_section_completed: false)
  end

private

  def destroy_postconditions
    return if check_page.nil?

    postconditions = check_page.check_conditions.filter { it != self && it.routing_page_id != it.check_page_id }
    postconditions.each(&:destroy!)
  end
end
