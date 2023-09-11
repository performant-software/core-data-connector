module CoreDataConnector
  module OwnablePolicy
    extend ActiveSupport::Concern

    def permitted_attributes
      [{ project_item_attributes: [:id, :project_id, :_destroy] }]
    end
  end
end