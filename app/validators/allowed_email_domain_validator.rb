class AllowedEmailDomainValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present?
      return if value =~ /\.gov\.uk\z/i

      # TODO: we might not want to check against current user domain
      # when we have a proper allow list?
      if record.respond_to?(:current_user) && record.current_user.present?
        user_domain_with_at = record.current_user.email
          .then { |email| email[email.rindex("@")..] }
        return if user_domain_with_at && value.end_with?(user_domain_with_at)
      end
    end

    record.errors.add(attribute, :non_government_email)
  end
end
