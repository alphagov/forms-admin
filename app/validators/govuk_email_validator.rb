class GovukEmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    # TODO: remove after Friday 3 Nov 2023 but keep else statement
    unless value =~ if FeatureService.enabled?("pentest_partners_access_enabled")
                      /(\.gov\.uk|@pentestpartners\.com)\z/i
                    else
                      /\.gov\.uk\z/i
                    end
      record.errors.add(attribute, :non_govuk_email)
    end
  end
end
