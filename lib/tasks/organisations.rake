namespace :organisations do
  desc "Update organisations table using data from GOV.UK"
  task fetch: :environment do
    include AdvisoryLock::DSL

    with_lock("forms-admin:organisations:fetch") do
      OrganisationsFetcher.new.call
    end
  end

  desc "Add organisation that is not in GOV.UK organisation database"
  task :create, %i[name] => :environment do |_, args|
    usage_message = "usage: rails organisations:create[<name>]".freeze
    abort usage_message if args[:name].blank?

    organisation = Organisation.find_by(name: args[:name])
    abort "Organisation already exists: #{organisation.inspect}" if organisation

    organisation = Organisation.create!(
      slug: args[:name].parameterize,
      name: args[:name],
    )

    puts "Created #{organisation.inspect}"
  end

  desc "Output summary data about each organisation as newline-delimited JSON"
  task summary: :environment do
    Organisation.with_users.find_each do |organisation|
      forms = Form.where(organisation_id: organisation.id)

      puts({
        id: organisation.id,
        slug: organisation.slug,
        name: organisation.name,
        forms: forms.count,
        live_forms: forms.select { |form| form.state == "live" }.count,
        groups: organisation.groups.count,
        mou_signatures: organisation.mou_signatures.count,
        users: organisation.users.count,
        organisation_admin_users: organisation.admin_users.count,
        default_group: organisation.default_group.present?,
        default_group_active: organisation.default_group&.active?,
        default_group_forms: organisation.default_group&.group_forms&.count,
        default_group_users: organisation.default_group&.memberships&.count,
      }.to_json)
    end
  end
end
