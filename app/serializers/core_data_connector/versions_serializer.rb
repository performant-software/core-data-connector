module CoreDataConnector
  class VersionsSerializer < BaseSerializer
    index_attributes :id, :uuid, :event, :item_id, :request_uuid, :created_at, :root_id,
                     :root_display_name, :root_uuid, :root_project_model_id, user: UsersSerializer

    index_attributes(:record_type) { |version| version.item_type.demodulize }
    index_attributes(:root_record_type) { |version| version.root_type&.demodulize }
    index_attributes(:attributes) { |version, _current_user, options| options[:attribute_changes].call(version) }
    index_attributes(:user_defined) { |version, _current_user, options| options[:user_defined_changes].call(version) }
    index_attributes(:metadata) { |version| version.meta }

    show_attributes(*index_attributes)
  end
end