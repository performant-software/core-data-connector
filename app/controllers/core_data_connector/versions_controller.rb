module CoreDataConnector
  class VersionsController < ApplicationController
    TRACKABLE_MODELS = %w[
      Event
      Instance
      Item
      MediaContent
      Organization
      Person
      Place
      Taxonomy
      Work
    ].freeze

    preloads :user

    protected

    def base_query
      scope = super

      if params[:project_id].present?
        authorize project, :show?
        scope = scope.where(project_id: project.id)
      elsif is_valid?
        authorize root_record, :show?
        scope = scope.where(root_type:
                              root_record.class.name, root_id: root_record.id)
      else
        return Version.none
      end

      params[:sort_by].present? ? scope :
        scope.order(created_at: :desc, id: :desc)
    end

    def load_records(items)
      preload_user_defined_fields [items].flatten

      super.merge(
        attribute_changes: method(:attribute_changes),
        user_defined_changes: method(:user_defined_changes)
      )
    end

    def attribute_changes(version)
      serialized = {}

      extract_changes(version).each do |attribute, (from, to)|
        next if attribute == 'user_defined'

        serialized[attribute] = { from: from, to: to }
      end

      serialized
    end

    def user_defined_changes(version)
      before, after = extract_changes(version)['user_defined']
      before ||= {}
      after ||= {}

      (before.keys | after.keys).filter_map do |uuid|
        from = before[uuid]
        to = after[uuid]

        next if from == to

        field = @user_defined_fields[uuid]

        {
          uuid: uuid,
          label: field&.column_name || uuid,
          data_type: field&.data_type,
          from: from,
          to: to
        }
      end
    end

    private

    def extract_changes(version)
      if version.object_changes.present?
        version.object_changes
      elsif version.event == 'destroy' && version.object.present?
        version.object.transform_values { |value| [value, nil] }
      else
        {}
      end
    end

    def preload_user_defined_fields(versions)
      uuids = versions.flat_map { |version| user_defined_uuids(version) }.uniq

      @user_defined_fields = UserDefinedFields::UserDefinedField
                               .where(uuid: uuids)
                               .index_by(&:uuid)
    end

    def user_defined_uuids(version)
      uuids = []

      if version.object_changes.present?
        before, after = version.object_changes['user_defined']
        uuids += (before || {}).keys + (after || {}).keys
      end

      if version.object.present?
        uuids += (version.object['user_defined'] || {}).keys
      end

      uuids
    end

    def is_valid?
      record_class.is_a?(Class) && record_class < ApplicationRecord && record_class.include?(Auditable)
    end

    def root_record
      @root_record ||= record_class.find(params[parent_param])
    end

    def record_class
      @record_class ||= parent_param && "CoreDataConnector::#{parent_param.to_s.delete_suffix('_id').classify}".safe_constantize
    end

    def parent_param
      @parent_param ||= TRACKABLE_MODELS.map { |model| :"#{model.underscore}_id" }
                                         .find { |key| params[key].present? }
    end

    def project
      @project ||= Project.find(params[:project_id])
    end
  end
end