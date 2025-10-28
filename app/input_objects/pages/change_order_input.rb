class Pages::ChangeOrderInput < BaseInput
  attr_accessor :form, :page_position_params, :confirm

  RADIO_OPTIONS = { yes: "yes", no: "no" }.freeze
  INPUT_PREFIX = "position_for_page_".freeze
  NUMERIC_PATTERN = /\A\d+\z/
  MAXIMUM = 1000

  validate :validate_positions

  with_options except_on: :preview do
    validates :confirm, presence: true, inclusion: { in: RADIO_OPTIONS.values }
  end

  def update_preview
    change_ordered_page_ids = Pages::ChangeOrderService.generate_new_page_order(page_ids_and_positions)
    @pages_preview_order = change_ordered_page_ids.map { |page_id| form.pages.find_by(id: page_id) }.compact
    @page_position_params = nil
  end

  def submit
    return false if invalid?

    Pages::ChangeOrderService.update_page_order(form:, page_ids_and_positions:) if confirmed?
    true
  end

  def pages
    return @pages_preview_order if @pages_preview_order
    return form.pages unless @page_position_params

    page_position_params.map { |name, _value| form.pages.find_by(id: page_id_from_input_name(name)) }.compact
  end

  def input_name(page)
    "#{Pages::ChangeOrderInput::INPUT_PREFIX}#{page.id}".to_sym
  end

private

  def confirmed?
    confirm == RADIO_OPTIONS[:yes]
  end

  def page_ids_and_positions
    page_position_params
      .map { |name, value| { page_id: page_id_from_input_name(name), new_position: value } }
  end

  def validate_positions
    page_position_params.each do |name, value|
      next if value.blank?

      if !NUMERIC_PATTERN.match?(value) || value.to_i < 1 || value.to_i > MAXIMUM
        errors.add(name.to_sym, I18n.t("activemodel.errors.models.pages/change_order_input.attributes.page_position.invalid", maximum: MAXIMUM))
      end
    end
  end

  def page_id_from_input_name(input_name)
    input_name[/#{Pages::ChangeOrderInput::INPUT_PREFIX}(\d+)/, 1].to_i
  end
end
