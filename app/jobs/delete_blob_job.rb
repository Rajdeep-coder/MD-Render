# app/jobs/delete_blob_job.rb
class DeleteBlobJob < ApplicationJob
  queue_as :default

  def perform(blob_id)
    blob = ActiveStorage::Blob.find_by(id: blob_id)
    blob.purge if blob.present?
  end
end
