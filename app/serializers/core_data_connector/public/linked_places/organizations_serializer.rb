module CoreDataConnector
  module Public
    module LinkedPlaces
      class OrganizationsSerializer < Base
        annotation_attributes(:id) { |organization| "#{base_url}/organizations/#{organization.uuid}" }
        annotation_attributes(:record_id) { |organization| organization.id }
        annotation_attributes(:title) { |organization| organization.name }
        annotation_attributes(:type) { 'Organization' }
        annotation_attributes :description, user_defined: UserDefinedSerializer
      end
    end
  end
end