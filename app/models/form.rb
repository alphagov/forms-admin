class Form < ApplicationRecord
  has_many :pages, -> { order(position: :asc) }, dependent: :destroy
  after_create :set_external_id

private

  def set_external_id
    update(external_id: id)
  end
end
