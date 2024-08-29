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
              instance_relationships: [
                related_record: [
                  primary_name: :name,
                  source_titles: :name,
                  project_model: :user_defined_fields
                ]
              ],
              item_relationships: [
                related_record: [
                  primary_name: :name,
                  source_titles: :name,
                  project_model: :user_defined_fields
                ]
              ],
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
              ],
              taxonomy_relationships: [
                related_record: [
                  :name,
                  project_model: :user_defined_fields
                ],
                project_model_relationship: :user_defined_fields
              ],
              work_relationships: [
                related_record: [
                  primary_name: :name,
                  source_titles: :name,
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
              instance_related_relationships: [
                primary_record: [
                  primary_name: :name,
                  source_titles: :name,
                  project_model: :user_defined_fields
                ],
                project_model_relationship: :user_defined_fields
              ],
              item_related_relationships: [
                primary_record: [
                  primary_name: :name,
                  source_titles: :name,
                  project_model: :user_defined_fields
                ],
                project_model_relationship: :user_defined_fields
              ],
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
              ],
              taxonomy_related_relationships: [
                primary_record: [
                  :name,
                  project_model: :user_defined_fields
                ],
                project_model_relationship: :user_defined_fields
              ],
              work_related_relationships: [
                primary_record: [
                  primary_name: :name,
                  source_titles: :name,
                  project_model: :user_defined_fields
                ],
                project_model_relationship: :user_defined_fields
              ],
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

          # Concrete class query
          query = search_query(query) if self.respond_to?(:search_query)

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
        # Includes
        include UserDefinedFields::Converter

        # Primary relationships
        has_many :event_relationships, -> {
          where(Relationship.arel_table.name => { related_record_type: CoreDataConnector::Event.to_s })
        }, as: :primary_record, class_name: Relationship.to_s

        has_many :instance_relationships, -> {
          where(Relationship.arel_table.name => { related_record_type: CoreDataConnector::Instance.to_s })
        }, as: :primary_record, class_name: Relationship.to_s

        has_many :item_relationships, -> {
          where(Relationship.arel_table.name => { related_record_type: CoreDataConnector::Item.to_s })
        }, as: :primary_record, class_name: Relationship.to_s

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

        has_many :taxonomy_relationships, -> {
          where(Relationship.arel_table.name => { related_record_type: CoreDataConnector::Taxonomy.to_s })
        }, as: :primary_record, class_name: Relationship.to_s

        has_many :work_relationships, -> {
          where(Relationship.arel_table.name => { related_record_type: CoreDataConnector::Work.to_s })
        }, as: :primary_record, class_name: Relationship.to_s

        # Related relationships
        has_many :event_related_relationships, -> {
          joins(:project_model_relationship)
            .where(Relationship.arel_table.name => { primary_record_type: CoreDataConnector::Event.to_s })
            .where(ProjectModelRelationship.arel_table.name => { allow_inverse: true })
        }, as: :related_record, class_name: Relationship.to_s

        has_many :instance_related_relationships, -> {
          joins(:project_model_relationship)
            .where(Relationship.arel_table.name => { primary_record_type: CoreDataConnector::Instance.to_s })
            .where(ProjectModelRelationship.arel_table.name => { allow_inverse: true })
        }, as: :related_record, class_name: Relationship.to_s

        has_many :item_related_relationships, -> {
          joins(:project_model_relationship)
            .where(Relationship.arel_table.name => { primary_record_type: CoreDataConnector::Item.to_s })
            .where(ProjectModelRelationship.arel_table.name => { allow_inverse: true })
        }, as: :related_record, class_name: Relationship.to_s

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

        has_many :taxonomy_related_relationships, -> {
          joins(:project_model_relationship)
            .where(Relationship.arel_table.name => { primary_record_type: CoreDataConnector::Taxonomy.to_s })
            .where(ProjectModelRelationship.arel_table.name => { allow_inverse: true })
        }, as: :related_record, class_name: Relationship.to_s

        has_many :work_related_relationships, -> {
          joins(:project_model_relationship)
            .where(Relationship.arel_table.name => { primary_record_type: CoreDataConnector::Work.to_s })
            .where(ProjectModelRelationship.arel_table.name => { allow_inverse: true })
        }, as: :related_record, class_name: Relationship.to_s

        # Include the ID attributes as a string by default
        search_attribute(:id) { uuid }
        search_attribute(:record_id) { id.to_s }
        search_attribute :uuid

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
          hash.merge!(user_defined_fields)

          # Include related records
          build_relationships hash unless skip_relationships

          # Add the year range for related events
          build_event_range hash

          hash
        end

        private

        def build_event_range(hash)
          min_range = nil
          max_range = nil

          events = [
            *event_relationships.map{ |r| r.related_record },
            *event_related_relationships.map{ |r| r.primary_record }
          ]

          events.each do |event|
            if min_range.nil? || (event.start_date&.start_date.present? && event.start_date.start_date.year < min_range)
              min_range = event.start_date&.start_date&.year
            end

            if min_range.nil? || (event.end_date&.start_date.present? && event.end_date.start_date.year < min_range)
              min_range = event.end_date&.start_date&.year
            end

            if max_range.nil? || (event.end_date&.end_date.present? && event.end_date.end_date.year > max_range)
              max_range = event.end_date&.end_date&.year
            end

            if max_range.nil? || (event.start_date&.end_date.present? && event.start_date.end_date.year > max_range)
              max_range = event.start_date&.end_date&.year
            end
          end

          hash['event_range_facet'] = [min_range, max_range] unless min_range.nil? || max_range.nil?
        end

        def build_inverse_relationship(relationship, hash)
          project_model_relationship = relationship.project_model_relationship
          key = project_model_relationship.uuid

          attributes = {
            inverse: true
          }

          user_defined = build_user_defined(relationship, project_model_relationship.user_defined_fields)

          hash[key] ||= []

          hash[key] << relationship
                         .primary_record
                         .to_search_json
                         .merge(user_defined)
                         .merge(attributes)
        end

        def build_relationship(relationship, hash)
          project_model_relationship = relationship.project_model_relationship
          key = project_model_relationship.uuid

          attributes = {
            inverse: false
          }

          user_defined = build_user_defined(relationship, project_model_relationship.user_defined_fields)

          hash[key] ||= []

          hash[key] << relationship
                         .related_record
                         .to_search_json
                         .merge(user_defined)
                         .merge(attributes)
        end

        def build_relationships(hash)
          event_relationships.each { |r| build_relationship(r, hash) }
          instance_relationships.each { |r| build_relationship(r, hash) }
          item_relationships.each { |r| build_relationship(r, hash) }
          media_content_relationships.each { |r| build_relationship(r, hash) }
          organization_relationships.each { |r| build_relationship(r, hash) }
          person_relationships.each { |r| build_relationship(r, hash) }
          place_relationships.each { |r| build_relationship(r, hash) }
          taxonomy_relationships.each { |r| build_relationship(r, hash) }
          work_relationships.each { |r| build_relationship(r, hash) }

          event_related_relationships.each { |r| build_inverse_relationship(r, hash) }
          instance_related_relationships.each { |r| build_inverse_relationship(r, hash) }
          item_related_relationships.each { |r| build_inverse_relationship(r, hash) }
          media_content_related_relationships.each { |r| build_inverse_relationship(r, hash) }
          organization_related_relationships.each { |r| build_inverse_relationship(r,hash) }
          person_related_relationships.each { |r| build_inverse_relationship(r, hash) }
          place_related_relationships.each { |r| build_inverse_relationship(r, hash) }
          taxonomy_related_relationships.each { |r| build_inverse_relationship(r, hash) }
          work_related_relationships.each { |r| build_inverse_relationship(r, hash) }
        end

        def build_user_defined(record, user_defined_fields)
          hash = {}

          user_defined_fields.each do |field|
            next unless record.user_defined

            value = convert_value(field, record.user_defined[field.uuid])
            next unless value.present?

            key = field.uuid
            hash[key] = value

            facet = %(Date Number Select Boolean).include?(field.data_type)
            hash["#{key}_facet"] = value if facet
          end

          hash
        end
      end
    end
  end
end
