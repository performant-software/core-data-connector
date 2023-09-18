class AddProjectModelReferences < ActiveRecord::Migration[7.0]
  def change
    add_reference :core_data_connector_organizations, :project_model
    add_reference :core_data_connector_people, :project_model
    add_reference :core_data_connector_places, :project_model
  end
end
