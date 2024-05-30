module CoreDataConnector
  class PlacePolicy < BasePolicy
    # Includes
    include MergeablePolicy
    include OwnablePolicy

    attr_reader :current_user, :place, :project_model_id, :project_id

    def initialize(current_user, place)
      @current_user = current_user
      @place = place

      @project_model_id = place&.project_model_id
      @project_id = place&.project_id
    end

    # Allowed create/update attributes.
    def permitted_attributes
      [ *ownable_attributes,
        user_defined: {},
        place_names_attributes: [:id, :name, :primary, :_destroy],
        place_geometry_attributes: [:id, :geometry_json, :_destroy],
        place_layers_attributes: [:id, :name, :layer_type, :url, :geometry, :_destroy]
      ]
    end

    # Include default ownable scope.
    class Scope < BaseScope
      include OwnableScope
    end
  end
end