# GOV.UK is the canonical source for organisations, so we need to keep our
# organisations up-to-date in order to provide accurate information on user
# membership of organisations.
#
# Based on similar code in Signon app:
# https://github.com/alphagov/signon/blob/b7a53e282c55d8ef3ab6369a7cb358b6ae100d27/lib/organisations_fetcher.rb
class OrganisationsFetcher
  def call
    organisations.each do |organisation_data|
      update_or_create_organisation(organisation_data)
    end
  rescue ActiveRecord::RecordInvalid => e
    raise "Couldn't save organisation #{e.record.slug} because: #{e.record.errors.full_messages.join(',')}"
  end

private

  def organisations
    @organisations ||= get_json_with_subsequent_pages(URI("https://www.gov.uk/api/organisations"))
  end

  def update_or_create_organisation(organisation_data)
    govuk_content_id = organisation_data[:details][:content_id]
    slug = organisation_data[:details][:slug]

    organisation = Organisation.find_by(govuk_content_id:) ||
      Organisation.find_by(slug:) ||
      Organisation.new(govuk_content_id:)

    update_data = {
      govuk_content_id:,
      slug:,
      name: organisation_data[:title],
      closed: organisation_data[:details][:govuk_status] == "closed",
    }

    organisation.update!(update_data)
  end

  def get_json_with_subsequent_pages(uri)
    next_page_uri = uri
    Enumerator.new do |yielder|
      while next_page_uri
        page = get_json(next_page_uri)
        page[:results].each { |i| yielder << i }
        next_page_uri = page.key?(:next_page_url) ? URI(page[:next_page_url]) : nil
      end
    end
  end

  def get_json(uri)
    response = Net::HTTP.get_response(uri)
    if response.is_a? Net::HTTPSuccess
      JSON.parse(response.body, symbolize_names: true)
    else
      raise "error fetching organisations: #{response.code}: #{response.body}"
    end
  end
end
