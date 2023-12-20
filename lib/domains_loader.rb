# We want to store our list of domains in source control
class DomainsLoader
  def call
    Domain.delete_all

    domains.each do |domain_data|
      create_domain(domain_data)
    end
  end

private

  def domains
    @domains ||= YAML.load(File.read("../forms-deploy/config/domains.yml"), symbolize_names: true)
  end

  def create_domain(domain_data)
    organisation = Organisation.find_by(govuk_content_id: domain_data[:organisation_content_id])

    create_data = {
      organisation_id: organisation&.id,
      domain: domain_data[:domain],
    }

    Domain.create!(create_data)
  end
end
