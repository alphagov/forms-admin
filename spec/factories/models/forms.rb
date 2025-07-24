FactoryBot.define do
  factory :form, parent: :form_record
end

def build_pages_list(pages)
  pages.each.with_index(1).each_cons(2) do |page_with_index, next_page_with_index|
    page, page_index = page_with_index
    next_page, _next_page_index = next_page_with_index

    page.position = page_index
    page.next_page = next_page&.id if page.is_a? Api::V1::PageResource

    yield page if block_given?
  end

  pages
end

def link_form_pages_and_conditions(form, pages = [], conditions = [])
  build_pages_list(pages) do |page|
    page.form = form

    if page.id.present?
      page.routing_conditions = conditions.select { |condition| condition.routing_page_id == page.id }
      page.check_conditions = conditions.select { |condition| condition.check_page_id == page.id }
      page.goto_conditions = conditions.select { |condition| condition.goto_page_id == page.id }
    end
  end
end

def build_form(*form_traits, pages: [], conditions: [], **form_attributes)
  form = build(:form, *form_traits, pages:, **form_attributes)
  link_form_pages_and_conditions(form, pages, conditions)
  form
end

def create_form(*form_traits, pages: [], conditions: [], **form_attributes)
  form = build_form(*form_traits, pages:, conditions:, **form_attributes)
  form.save!
  form
end
