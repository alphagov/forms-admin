class Form < ActiveResource::Base
  self.site = "#{ENV['API_BASE']}/api/v1"
  self.include_format_in_path = false
  headers["X-API-Token"] = ENV["API_KEY"]

  has_many :pages

  def last_page
    pages.find { |p| !p.has_next_page? }
  end

  def save_page(page)
    page.save && append_page(page)
  end

  def append_page(page)
    return true if pages.empty?

    # if there is already a last page, set its next_page value to our new page. This
    # should probably be done in the API, here we cannot add a page and set
    # the next_page value atomically
    current_last_page = last_page
    current_last_page.next_page = page.id
    current_last_page.save!
  end
end
