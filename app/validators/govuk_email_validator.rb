class GovukEmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\.gov\.uk\z/i
      record.errors.add(attribute, :non_govuk_email)
    end
  end
end
