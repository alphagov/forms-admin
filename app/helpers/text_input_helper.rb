module TextInputHelper
  def strip_carriage_returns!(input)
    input.gsub!(/\r\n?/, "\n") if input.present?
  end
end
