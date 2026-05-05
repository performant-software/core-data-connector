module CoreDataConnector
  class Job < ApplicationRecord
    JOB_STATUS_INITIALIZING = 'initializing'
    JOB_STATUS_PROCESSING = 'processing'
    JOB_STATUS_COMPLETED = 'completed'
    JOB_STATUS_FAILED = 'failed'

    JOB_TYPE_EXPORT = 'export'
    JOB_TYPE_IMPORT = 'import'
    JOB_TYPE_IIIF_MANIFEST = 'iiif_manfest'

    # Includes
    include Rails.application.routes.url_helpers

    # Relationships
    belongs_to :project
    belongs_to :user

    # Active storage
    has_one_attached :file

    # Callbacks
    after_create_commit :queue_export_job, if: :export?
    after_create_commit :queue_import_job, if: :import?
    after_create_commit :queue_generate_iiif_manifest_job, if: :generate_iiif_manifest?

    def self.create_iiif_manifest_job!( item, project_model_relationship_id, current_user)
      job = Job.new
      
      job.job_type = JOB_TYPE_IIIF_MANIFEST
      job.extra = {
        item_class_name: item.class.to_s, 
        item_id: item.id, 
        project_model_relationship_id: project_model_relationship_id
      }
      job.user = current_user
      job.project_id = item.project_model.project_id
      job.save!
    end

    def download_url
      return nil unless file.attached?

      rails_blob_url file, disposition: 'attachment'
    end

    def export?
      job_type == JOB_TYPE_EXPORT
    end

    def import?
      job_type == JOB_TYPE_IMPORT
    end

    def generate_iiif_manifest?
      job_type == JOB_TYPE_IIIF_MANIFEST
    end

    private

    def queue_export_job
      ExportCsvJob.perform_later(id)
    end

    def queue_import_job
      ImportCsvJob.perform_later(id)
    end

    def queue_generate_iiif_manifest_job
      IiifManifestJob.perform_later(id)
    end

  end
end