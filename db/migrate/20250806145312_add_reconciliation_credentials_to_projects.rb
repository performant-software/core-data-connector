class AddReconciliationCredentialsToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :core_data_connector_projects, :reconciliation_credentials, :jsonb, default: {}
  end
end
