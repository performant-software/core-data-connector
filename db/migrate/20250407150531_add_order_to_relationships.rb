class AddOrderToRelationships < ActiveRecord::Migration[7.0]
  def change
    add_column :core_data_connector_relationships, :order, :integer, default: 0
  end
end
