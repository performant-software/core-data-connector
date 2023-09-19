module CoreDataConnector
  class PlacePolicy < BasePolicy
    include OwnablePolicy

    attr_reader :current_user, :place, :project_id

    def initialize(current_user, place)
      @current_user = current_user
      @place = place
      @project_id = place&.project_id
    end

    # Allowed create/update attributes.
    def permitted_attributes
      attrs = [user_defined: {}]
      attrs << ownable_attributes
      attrs << { place_names_attributes: [:id, :name, :primary, :_destroy] }
      attrs
    end

    # Include default ownable scope.
    class Scope < BaseScope
      include OwnableScope
    end
  end
end