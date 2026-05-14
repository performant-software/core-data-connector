class AddMergedNameToRecordMerges < ActiveRecord::Migration[8.0]
  def change
    add_column :core_data_connector_record_merges, :merged_name, :string
  end
end
