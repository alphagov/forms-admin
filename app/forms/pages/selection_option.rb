class Pages::SelectionOption < BaseForm
  attr_accessor :name

  def init(name)
    @name = name
  end
end
