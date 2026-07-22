module CoreDataConnector
  class VersionsSerializer < BaseSerializer
    index_attributes :id, :uuid, :event, :item_id, :request_uuid, :created_at, :root_id, user: UsersSerializer

    ROOT_ATTRIBUTES = {
      root_display_name: :display_name,
      root_uuid: :uuid,
      root_project_model_id: :project_model_id
    }.freeze

    index_attributes(:record_type) { |version| version.item_type.demodulize }
    index_attributes(:root_record_type) { |version| version.root_type&.demodulize }
    index_attributes(:attributes) { |version, _current_user, options| options[:attribute_changes].call(version) }
    index_attributes(:user_defined) { |version, _current_user, options| options[:user_defined_changes].call(version) }
    index_attributes(:metadata) { |version| version.meta }

    ROOT_ATTRIBUTES.each do |key, attribute|
      index_attributes(key) { |version| version.root&.public_send(attribute) }
    end

    show_attributes(*index_attributes)
  end
end