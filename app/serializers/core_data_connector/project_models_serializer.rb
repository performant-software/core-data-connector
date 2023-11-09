module CoreDataConnector
  class ProjectModelsSerializer < BaseSerializer
    # Includes
    include UserDefinedFields::DefineableSerializer

    index_attributes :id, :project_id, :name, :name_singular, :model_class, :model_class_view, :slug, project: ProjectsSerializer

    index_attributes(:has_shares) do |project_model|
      !project_model.project_model_shares.empty?
    end

    show_attributes :id, :project_id, :name, :name_singular, :model_class, :model_class_view, :slug, project: ProjectsSerializer,
                    project_model_relationships: [:id, :related_model_id, :name, :multiple, :slug, :allow_inverse,
                                                  :inverse_name, :inverse_multiple, related_model: ProjectModelsSerializer,
                                                  user_defined_fields: UserDefinedFields::UserDefinedFieldsSerializer],
                    inverse_project_model_relationships: [:id, :primary_model_id, :name, :multiple, :slug, :allow_inverse,
                                                          :inverse_name, :inverse_multiple, primary_model: ProjectModelsSerializer,
                                                          user_defined_fields: UserDefinedFields::UserDefinedFieldsSerializer],
                    project_model_accesses: [:id, :project_id, project: ProjectsSerializer],
                    project_model_shares: [:id, :project_model_access_id, project_model_access: ProjectModelAccessesSerializer]

    show_attributes(:has_shares) do |project_model|
      !project_model.project_model_shares.empty?
    end
  end
end