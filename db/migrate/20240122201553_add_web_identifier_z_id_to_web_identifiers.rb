class AddWebIdentifierZIdToWebIdentifiers < ActiveRecord::Migration[7.0]
  def change
    add_column :core_data_connector_web_identifiers, :z_web_identifier_id, :integer
  end
end