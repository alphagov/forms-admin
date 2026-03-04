class AddAgreementTypeToMouSignatures < ActiveRecord::Migration[8.1]
  def change
    add_column :mou_signatures, :agreement_type, :string, null: false, default: "crown"
  end
end
