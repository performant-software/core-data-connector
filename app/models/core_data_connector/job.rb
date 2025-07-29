module CoreDataConnector
  class Job < ApplicationRecord
    JOB_STATUS_INITIALIZING = 'initializing'
    JOB_STATUS_PROCESSING = 'processing'
    JOB_STATUS_COMPLETED = 'completed'
    JOB_STATUS_FAILED = 'failed'

    JOB_TYPE_IMPORT = 'import'

    # Includes
    include Rails.application.routes.url_helpers

    # Relationships
    belongs_to :project
    belongs_to :user

    # Active storage
    has_one_attached :file

    # Callbacks
    after_create_commit :after_create

    def download_url
      return nil unless file.attached?

      rails_blob_url file, disposition: 'attachment'
    end

    private

    def after_create
      ImportCsvJob.perform_later(id) if job_type == JOB_TYPE_IMPORT
    end
  end
end