module CoreDataConnector
  class VersionsSerializer < BaseSerializer
    index_attributes :id, :uuid, :event, :item_id, :request_uuid, :created_at, user: UsersSerializer

    index_attributes(:record_type) { |version| version.item_type.demodulize }

    index_attributes(:roots) do |version|
      Array(version.roots).map do |root|
        {
          record_type: root['type']&.demodulize,
          id: root['id'],
          display_name: root['display_name'],
          uuid: root['uuid'],
          project_model_id: root['project_model_id']
        }
      end
    end
    index_attributes(:attributes) { |version, _current_user, options| options[:attribute_changes].call(version) }
    index_attributes(:user_defined) { |version, _current_user, options| options[:user_defined_changes].call(version) }
    index_attributes(:metadata) { |version| version.meta }

    show_attributes(*index_attributes)
  end
end