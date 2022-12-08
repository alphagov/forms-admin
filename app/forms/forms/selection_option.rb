class Forms::SelectionOption
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :name

  def init(name)
    @name = name
  end
end
