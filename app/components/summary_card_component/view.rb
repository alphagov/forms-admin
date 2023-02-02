# frozen_string_literal: true

class SummaryCardComponent::View < ViewComponent::Base
  renders_one :header_actions

  def initialize(title:, rows:, hint: nil, heading_level: 2, id_suffix: nil)
    @title = title
    @hint = hint
    @heading_level = heading_level
    @rows = rows
    @id_suffix = id_suffix
    super
  end

  def summary_rows
    @rows
  end

private

  attr_accessor :title, :hint, :heading_level, :id_suffix

  def row_title(key)
    return key.parameterize if id_suffix.nil?

    "#{key.parameterize}-#{id_suffix}"
  end
end
