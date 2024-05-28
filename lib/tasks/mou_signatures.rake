namespace :mou_signatures do
  desc "Add MOU signature that was done offline"
  task :create, %i[user_email organisation_name agreed_at_date] => :environment do |_, args|
    usage_message = "usage: rake mou_signatures:create[<user_email>, <organisation_name>, <agreed_at_date>]".freeze
    abort usage_message if args[:user_email].blank? || args[:organisation_name].blank? || args[:agreed_at_date].blank?

    user = User.find_by!(email: args[:user_email])
    organisation = Organisation.find_by!(name: args[:organisation_name])
    agreed_at_date = Date.iso8601(args[:agreed_at_date])

    mou_signature = MouSignature.create!(user:, organisation:, created_at: agreed_at_date)

    puts "Added MOU signature for User: #{mou_signature.user.name} and Organisation: #{mou_signature.organisation.name} signed at: #{mou_signature.created_at}"
  end

  desc "Update the organisation that an MOU was signed for"
  task :update_organisation, %i[user_email current_organisation_name target_organisation_name] => :environment do |_, args|
    usage_message = "usage: rake mou_signatures:update_organisation[<user_email>, <current_organisation_name>, <target_organisation_name>]".freeze
    abort usage_message if args[:user_email].blank? || args[:current_organisation_name].blank? || args[:target_organisation_name].blank?

    user = User.find_by(email: args[:user_email])
    abort "User with email address: #{args[:user_email]} not found" unless user
    current_organisation = Organisation.find_by(name: args[:current_organisation_name])
    abort "Organisation with name: #{args[:current_organisation_name]} not found" unless current_organisation
    target_organisation = Organisation.find_by(name: args[:target_organisation_name])
    abort "Organisation with name: #{args[:target_organisation_name]} not found" unless target_organisation

    mou_signature = MouSignature.find_by(user:, organisation: current_organisation)
    abort "MOU signature for User: #{user.email} and Organisation: #{current_organisation.name} not found" unless mou_signature

    mou_signature.organisation = target_organisation
    mou_signature.save!

    puts "Updated MOU signature for User: #{user.email} and Organisation: #{current_organisation.name} to be for #{target_organisation.name}"
  end
end
