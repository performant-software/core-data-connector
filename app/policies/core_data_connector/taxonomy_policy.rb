module CoreDataConnector
  class TaxonomyPolicy < BasePolicy
    include OwnablePolicy

    attr_reader :current_user, :taxonomy, :project_model_id, :project_id

    def initialize(current_user, taxonomy)
      @current_user = current_user
      @taxonomy = taxonomy

      @project_model_id = taxonomy&.project_model_id
      @project_id = taxonomy&.project_id
    end

    def permitted_attributes
      [ *ownable_attributes,
        :name
      ]
    end

    class Scope < BaseScope
      include OwnableScope
    end
  end
end