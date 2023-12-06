module CoreDataConnector
  module Public
    module PublicSerializer
      extend ActiveSupport::Concern

      included do
        index_attributes *self.superclass.index_attributes
        show_attributes *self.superclass.show_attributes

        index_attributes(:user_defined) do |record|
          next unless record.respond_to?(:user_defined)

          hash = {}

          record.project_model.user_defined_fields.each do |user_defined_field|
            key = user_defined_field.uuid
            next unless record.user_defined[key].present?

            hash[key] = {
              label: user_defined_field.column_name,
              value: record.user_defined[key]
            }
          end

          record.relationships.each do |relationship|
            user_defined_fields = relationship.project_model_relationship.user_defined_fields

            user_defined_fields.each do |user_defined_field|
              key = user_defined_field.uuid
              next unless relationship.user_defined[key].present?

              hash[key] = {
                label: user_defined_field.column_name,
                value: relationship.user_defined[key]
              }
            end
          end

          record.related_relationships.each do |relationship|
            user_defined_fields = relationship.project_model_relationship.user_defined_fields

            user_defined_fields.each do |user_defined_field|
              key = user_defined_field.uuid
              next unless relationship.user_defined[key].present?

              hash[key] = {
                label: user_defined_field.column_name,
                value: relationship.user_defined[key]
              }
            end
          end

          hash
        end
      end
    end
  end
end