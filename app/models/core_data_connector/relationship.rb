module CoreDataConnector
  class Relationship < ApplicationRecord
    # Includes
    include Export::Relationship
    include UserDefinedFields::Fieldable

    # Relationships
    belongs_to :project_model_relationship
    belongs_to :primary_record, polymorphic: true
    belongs_to :related_record, polymorphic: true

    belongs_to :related_event, -> { where(Relationship.arel_table.name => { related_record_type: Event.to_s }) }, class_name: Event.to_s, foreign_key: :related_record_id, optional: true
    belongs_to :related_instance, -> { where(Relationship.arel_table.name => { related_record_type: Instance.to_s }) }, class_name: Instance.to_s, foreign_key: :related_record_id, optional: true
    belongs_to :related_item, -> { where(Relationship.arel_table.name => { related_record_type: Item.to_s }) }, class_name: Item.to_s, foreign_key: :related_record_id, optional: true
    belongs_to :related_media_content, -> { where(Relationship.arel_table.name => { related_record_type: MediaContent.to_s }) }, class_name: MediaContent.to_s, foreign_key: :related_record_id, optional: true
    belongs_to :related_organization, -> { where(Relationship.arel_table.name => { related_record_type: Organization.to_s }) }, class_name: Organization.to_s, foreign_key: :related_record_id, optional: true
    belongs_to :related_person, -> { where(Relationship.arel_table.name => { related_record_type: Person.to_s }) }, class_name: Person.to_s, foreign_key: :related_record_id, optional: true
    belongs_to :related_place, -> { where(Relationship.arel_table.name => { related_record_type: Place.to_s }) }, class_name: Place.to_s, foreign_key: :related_record_id, optional: true
    belongs_to :related_taxonomy, -> { where(Relationship.arel_table.name => { related_record_type: Taxonomy.to_s }) }, class_name: Taxonomy.to_s, foreign_key: :related_record_id, optional: true
    belongs_to :related_work, -> { where(Relationship.arel_table.name => { related_record_type: Work.to_s }) }, class_name: Work.to_s, foreign_key: :related_record_id, optional: true

    belongs_to :inverse_related_event, -> { where(Relationship.arel_table.name => { primary_record_type: Event.to_s }) }, class_name: Event.to_s, foreign_key: :primary_record_id, optional: true
    belongs_to :inverse_related_instance, -> { where(Relationship.arel_table.name => { primary_record_type: Instance.to_s }) }, class_name: Instance.to_s, foreign_key: :primary_record_id, optional: true
    belongs_to :inverse_related_item, -> { where(Relationship.arel_table.name => { primary_record_type: Item.to_s }) }, class_name: Item.to_s, foreign_key: :primary_record_id, optional: true
    belongs_to :inverse_related_media_content, -> { where(Relationship.arel_table.name => { primary_record_type: MediaContent.to_s }) }, class_name: MediaContent.to_s, foreign_key: :primary_record_id, optional: true
    belongs_to :inverse_related_organization, -> { where(Relationship.arel_table.name => { primary_record_type: Organization.to_s }) }, class_name: Organization.to_s, foreign_key: :primary_record_id, optional: true
    belongs_to :inverse_related_person, -> { where(Relationship.arel_table.name => { primary_record_type: Person.to_s }) }, class_name: Person.to_s, foreign_key: :primary_record_id, optional: true
    belongs_to :inverse_related_place, -> { where(Relationship.arel_table.name => { primary_record_type: Place.to_s }) }, class_name: Place.to_s, foreign_key: :primary_record_id, optional: true
    belongs_to :inverse_related_taxonomy, -> { where(Relationship.arel_table.name => { primary_record_type: Taxonomy.to_s }) }, class_name: Taxonomy.to_s, foreign_key: :primary_record_id, optional: true
    belongs_to :inverse_related_work, -> { where(Relationship.arel_table.name => { primary_record_type: Work.to_s }) }, class_name: Work.to_s, foreign_key: :primary_record_id, optional: true

    # Delegates
    delegate :project_id, to: :project_model_relationship

    # User defined fields parent
    resolve_defineable -> (relationship) { relationship.project_model_relationship }
  end
end