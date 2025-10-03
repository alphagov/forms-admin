class PageRepository
  class << self
    def move_page(record, direction)
      record.move_page(direction)
      record
    end
  end
end
