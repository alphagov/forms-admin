module TextInputHelper
  def strip_carriage_returns!(input)
    input.presence&.gsub!(/\r\n?/, "\n")
  end
end
