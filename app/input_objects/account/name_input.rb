class Account::NameInput < BaseInput
  attr_accessor :user, :name

  validates :name, presence: true

  def submit
    return false if invalid?

    user.name = name
    user.save!
  end

  def assign_form_values
    self.name = user.name
    self
  end
end
