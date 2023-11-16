module CoreDataConnector
  module Search
    module Base
      extend ActiveSupport::Concern

      class_methods do
        def apply_preloads(records, project_model_ids)
          # Preload project_model
          Preloader.new(
            records: records,
            associations: [
              project_model: [:project, :user_defined_fields]
            ]
          ).call

          # Preload any associations from the concrete class
          if self.respond_to?(:preloads) && preloads.present?
            Preloader.new(
              records: records,
              associations: preloads
            ).call
          end

          # Preload primary relationships
          Preloader.new(
            records: records,
            associations: [
              media_content_relationships: [
                related_record: [
                  project_model: :user_defined_fields
                ],
                project_model_relationship: :user_defined_fields
              ],
              organization_relationships: [
                related_record: [
                  :primary_name,
                  :organization_names,
                  project_model: :user_defined_fields
                ],
                project_model_relationship: :user_defined_fields
              ],
              person_relationships: [
                related_record: [
                  :primary_name,
                  :person_names,
                  project_model: :user_defined_fields
                ],
                project_model_relationship: :user_defined_fields
              ],
              place_relationships: [
                related_record: [
                  :place_geometry,
                  :primary_name,
                  :place_names,
                  project_model: :user_defined_fields
                ],
                project_model_relationship: :user_defined_fields
              ]
            ],
            scope: (
              Relationship
                .joins(:project_model_relationship)
                .where(core_data_connector_project_model_relationships: { primary_model_id: project_model_ids })
            )
          ).call

          # Preload related relationships
          Preloader.new(
            records: records,
            associations: [
              media_content_related_relationships: [
                primary_record: [
                  project_model: :user_defined_fields
                ],
                project_model_relationship: :user_defined_fields
              ],
              organization_related_relationships: [
                primary_record: [
                  :primary_name,
                  :organization_names,
                  project_model: :user_defined_fields
                ],
                project_model_relationship: :user_defined_fields
              ],
              person_related_relationships: [
                primary_record: [
                  :primary_name,
                  :person_names,
                  project_model: :user_defined_fields
                ],
                project_model_relationship: :user_defined_fields
              ],
              place_related_relationships: [
                primary_record: [
                  :place_geometry,
                  :primary_name,
                  :place_names,
                  project_model: :user_defined_fields
                ],
                project_model_relationship: :user_defined_fields
              ]
            ],
            scope: (
              Relationship
                .joins(:project_model_relationship)
                .where(core_data_connector_project_model_relationships: { related_model_id: project_model_ids })
            )
          ).call
        end

        def for_search(project_model_ids, &block)
          # Base query
          query = all_records_by_project_model(project_model_ids)

          query.find_in_batches(batch_size: 1000) do |records|
            # Apply the preloads for the current batch
            apply_preloads records, project_model_ids

            # Call the block for the current batch
            block.call(records)
          end
        end

        def search_attribute(*attrs, &block)
          name, options = attrs

          @attrs ||= []
          @attrs << { name: name, block: block}.merge(options || {})
        end

        def search_attributes
          @attrs
        end
      end

      included do
        # Primary relationships
        has_many :media_content_relationships, -> {
          where(Relationship.arel_table.name => { related_record_type: CoreDataConnector::MediaContent.to_s })
        }, as: :primary_record, class_name: Relationship.to_s

        has_many :organization_relationships, -> {
          where(Relationship.arel_table.name => { related_record_type: CoreDataConnector::Organization.to_s })
        }, as: :primary_record, class_name: Relationship.to_s

        has_many :person_relationships, -> {
          where(Relationship.arel_table.name => { related_record_type: CoreDataConnector::Person.to_s })
        }, as: :primary_record, class_name: Relationship.to_s

        has_many :place_relationships, -> {
          where(Relationship.arel_table.name => { related_record_type: CoreDataConnector::Place.to_s })
        }, as: :primary_record, class_name: Relationship.to_s

        # Related relationships
        has_many :media_content_related_relationships, -> {
          joins(:project_model_relationship)
            .where(Relationship.arel_table.name => { primary_record_type: CoreDataConnector::MediaContent.to_s })
            .where(ProjectModelRelationship.arel_table.name => { allow_inverse: true })
        }, as: :related_record, class_name: Relationship.to_s

        has_many :organization_related_relationships, -> {
          joins(:project_model_relationship)
            .where(Relationship.arel_table.name => { primary_record_type: CoreDataConnector::Organization.to_s })
            .where(ProjectModelRelationship.arel_table.name => { allow_inverse: true })
        }, as: :related_record, class_name: Relationship.to_s

        has_many :person_related_relationships, -> {
          joins(:project_model_relationship)
            .where(Relationship.arel_table.name => { primary_record_type: CoreDataConnector::Person.to_s })
            .where(ProjectModelRelationship.arel_table.name => { allow_inverse: true })
        }, as: :related_record, class_name: Relationship.to_s

        has_many :place_related_relationships, -> {
          joins(:project_model_relationship)
            .where(Relationship.arel_table.name => { primary_record_type: CoreDataConnector::Place.to_s })
            .where(ProjectModelRelationship.arel_table.name => { allow_inverse: true })
        }, as: :related_record, class_name: Relationship.to_s

        # Include the ID attribute as a string by default
        search_attribute(:id) do
          id.to_s
        end

        # Include the project model name as the record "type"
        search_attribute(:type, facet: true) do
          project_model.name
        end

        # Uses the specified attributes to create a JSON object. We'll skip relationships by default as to
        # not create an infinite loop while serializing related records.
        def to_search_json(skip_relationships = true)
          hash = {}

          # Add attributes defined by the concrete-class
          self.class.search_attributes.each do |attr|
            name = attr[:name]

            # Extract the value for the attribute
            if attr[:block].present?
              value = instance_eval(&attr[:block])
            else
              value = self.send(attr[:name])
            end

            # Skip the property of the value is empty
            next if value.nil?

            # Add the name/value pair to the JSON
            hash[name] = value

            # If the attribute should be included as a facet, include the "_facet" attribute
            hash["#{name}_facet".to_sym] = value if attr[:facet]
          end

          # Add user-defined fields
          user_defined_fields = build_user_defined(self, project_model.user_defined_fields)
          hash.merge!({ user_defined: user_defined_fields })

          # Include related records
          build_relationships hash unless skip_relationships

          hash
        end

        private

        def build_inverse_relationship(relationship, hash, key)
          project_model_relationship = relationship.project_model_relationship

          attributes = {
            type: project_model_relationship.inverse_name,
            user_defined: build_user_defined(relationship, project_model_relationship.user_defined_fields)
          }

          hash[key] ||= []
          hash[key] << relationship.primary_record.to_search_json.merge(attributes)
        end

        def build_relationship(relationship, hash, key)
          project_model_relationship = relationship.project_model_relationship

          attributes = {
            type: project_model_relationship.name,
            user_defined: build_user_defined(relationship, project_model_relationship.user_defined_fields)
          }

          hash[key] ||= []
          hash[key] << relationship.related_record.to_search_json.merge(attributes)
        end

        def build_relationships(hash)
          media_content_relationships.each { |r| build_relationship(r, hash, :related_media) }
          organization_relationships.each { |r| build_relationship(r, hash, :related_organizations) }
          person_relationships.each { |r| build_relationship(r, hash, :related_people) }
          place_relationships.each { |r| build_relationship(r, hash, :related_places) }

          media_content_related_relationships.each { |r| build_inverse_relationship(r, hash, :related_media) }
          organization_related_relationships.each { |r| build_inverse_relationship(r,hash, :related_organizations) }
          person_related_relationships.each { |r| build_inverse_relationship(r, hash, :related_people) }
          place_related_relationships.each { |r| build_inverse_relationship(r, hash, :related_places) }
        end

        def build_user_defined(record, user_defined_fields)
          fields = []

          user_defined_fields.each do |field|
            value = record.user_defined[field.uuid]
            next unless value.present?

            hash = { label: field.column_name, value: value }

            facet = %(Date Number Select Boolean).include?(field.data_type)
            hash = hash.merge({ value_facet: value }) if facet

            fields << hash
          end

          fields
        end
      end
    end
  end
end