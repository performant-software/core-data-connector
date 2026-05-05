module CoreDataConnector
  class IiifManifestJob < ApplicationJob

    def perform(job_id)
      job = Job.find(job_id)

      item_class_name = job.extra["item_class_name"]
      item_class = Kernel.const_get(item_class_name)
      item_id = job.extra["item_id"] 
      project_model_relationship_id = job.extra["project_model_relationship_id"]

      # Update the job status
      job.update(status: Job::JOB_STATUS_PROCESSING)
      error = nil
      
      begin
        service = Iiif::Manifest.new
        service.reset_manifests_by_type!(item_class, {
          id: item_id,
          project_model_relationship_id: project_model_relationship_id,
          limit: ENV['IIIF_MANIFEST_ITEM_LIMIT']
        })
      rescue StandardError => standard_error
        error = standard_error
      end

      # Update the job status
      if error
        job.update(status: Job::JOB_STATUS_COMPLETED)
      else
        log_errors [error]
        job.update(status: Job::JOB_STATUS_FAILED)
      end
    end
  end
end
