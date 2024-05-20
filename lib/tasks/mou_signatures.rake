namespace :mou_signatures do
  desc "Update the organisation that an MOU was signed for"
  task :update_organisation, %i[user_name current_organisation_name target_organisation_name] => :environment do |_, args|
    usage_message = "usage: rake mou_signatures:update_organisation[<user_name>, <current_organisation_name>, <target_organisation_name>".freeze
    abort usage_message if args[:user_name].blank? || args[:current_organisation_name].blank? || args[:target_organisation_name].blank?

    user = User.find_by(name: args[:user_name])
    abort "User with name: #{args[:user_name]} not found" unless user
    current_organisation = Organisation.find_by(name: args[:current_organisation_name])
    abort "Organisation with name: #{args[:current_organisation_name]} not found" unless current_organisation
    target_organisation = Organisation.find_by(name: args[:target_organisation_name])
    abort "Organisation with name: #{args[:target_organisation_name]} not found" unless target_organisation

    mou_signature = MouSignature.find_by(user:, organisation: current_organisation)
    abort "MOU signature for User: #{user.name} and Organisation: #{current_organisation.name} not found" unless mou_signature

    mou_signature.organisation = target_organisation
    mou_signature.save!

    puts "Updated MOU signature for User: #{user.name} and Organisation: #{current_organisation.name} to be for #{target_organisation.name}"
  end
end
