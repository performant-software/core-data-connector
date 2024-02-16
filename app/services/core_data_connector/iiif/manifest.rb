module CoreDataConnector
  module Iiif
    class Manifest
      def find_label(record)
        if record.is_a?(Place)
          record.name
        elsif record.is_a?(Instance) || record.is_a?(Item) || record.is_a?(Work)
          record.primary_name&.name&.name
        end
      end

      def reset_manifests
        # Find all project models that have a relationship
        ProjectModel.model_classes.each do |model_class|
          next unless model_class.ancestors.include?(Manifestable)
          reset_manifests_by_type model_class
        end
      end

      def reset_manifests_by_type(model_class, options = {})
        service = TripleEyeEffable::Presentation.new

        query = build_query(model_class, options)
        apply_preloads(query, options)

        query.find_each do |record|
          # Build a mapping of all of the related resources indexed by project_model_relationship
          hash = {}

          # Generate the manifest label for the current record
          label = find_label(record)

          record.relationships.each do |relationship|
            project_model_relationship = relationship.project_model_relationship
            resource = relationship.related_record

            add_resource hash, project_model_relationship, resource
          end

          record.related_relationships.each do |relationship|
            project_model_relationship = relationship.project_model_relationship
            resource = relationship.primary_record

            add_resource hash, project_model_relationship, resource
          end

          # Iterate over all of the relationships and build a manifest for each
          hash.keys.each do |project_model_relationship_uuid|
            info = hash[project_model_relationship_uuid]

            identifier = [
              'core_data',
              'public',
              model_class.model_name.route_key,
              record.uuid,
              'manifests',
              project_model_relationship_uuid
            ].join('/')

            # Create or update the manifest records
            project_model_relationship_id = info[:id]
            manifest = find_manifest(record, project_model_relationship_id)

            if manifest.nil?
              manifest = CoreDataConnector::Manifest.new(
                manifestable: record,
                project_model_relationship_id: project_model_relationship_id,
                thumbnail: info[:resources].first,
                identifier: identifier,
                label: info[:name]
              )
            end

            manifest.content = service.create_manifest(
              id: "#{ENV['HOSTNAME']}/#{identifier}",
              label: I18n.t('services.iiif.manifest.label', name: label, relationship: info[:name]),
              resource_ids: info[:resources]
            )

            manifest.save
          end
        end
      end

      private

      def add_resource(hash, project_model_relationship, resource)
        key = project_model_relationship.uuid

        hash[key] ||= {
          id: project_model_relationship.id,
          name: project_model_relationship.name,
          resources: []
        }

        hash[key][:resources] << resource.resource_description.resource_id
      end

      def apply_preloads(query, options)
        relationships_scope = Relationship
                                .where(related_record_type: MediaContent.to_s)

        if options[:project_model_relationship_id].present?
          relationships_scope = relationships_scope.where(
            project_model_relationship_id: options[:project_model_relationship_id]
          )
        end

        Preloader.new(
          records: query,
          associations: [
            relationships: [:project_model_relationship, :related_record]
          ],
          scope: relationships_scope
        ).call

        related_relationships_scope = Relationship
                                        .joins(:project_model_relationship)
                                        .where(primary_record_type: MediaContent.to_s)
                                        .where(project_model_relationship: {
                                          allow_inverse: true
                                        })

        if options[:project_model_relationship_id].present?
          related_relationships_scope = related_relationships_scope.where(
            project_model_relationship_id: options[:project_model_relationship_id]
          )
        end

        Preloader.new(
          records: query,
          associations: [
            related_relationships: [:project_model_relationship, :primary_record]
          ],
          scope: related_relationships_scope
        ).call
      end

      def build_query(model_class, options)
        primary_query = ProjectModel
                          .joins(project_model_relationships: [:primary_model, :related_model])
                          .where(ProjectModel.arel_table[:id].eq(model_class.arel_table[:project_model_id]))
                          .where(related_model: { model_class: MediaContent.to_s })

        related_query = ProjectModel
                          .joins(project_model_relationships: [:primary_model, :related_model])
                          .where(ProjectModel.arel_table[:id].eq(model_class.arel_table[:project_model_id]))
                          .where(project_model_relationships: { allow_inverse: true })
                          .where(primary_model: { model_class: MediaContent.to_s })

        query = model_class
                  .where(primary_query.or(related_query).arel.exists)


        if options[:id].present?
          query = query.where(id: options[:id])
        end

        query
      end

      def find_manifest(record, project_model_relationship_id)
        record.manifests.select{ |m| m.project_model_relationship_id == project_model_relationship_id }.first
      end

    end
  end
end