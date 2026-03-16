class RemoveDefaultValueForMouSignatureAgreementType < ActiveRecord::Migration[8.1]
  def up
    change_column_default :mou_signatures, :agreement_type, nil
  end

  def down
    change_column_default :mou_signatures, :agreement_type, "crown"
  end
end
