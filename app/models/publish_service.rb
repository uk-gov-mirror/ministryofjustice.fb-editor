class PublishService < ApplicationRecord
  validates :deployment_environment, :status, :service_id, presence: true
  validates :deployment_environment, inclusion: { in: %w(dev production) }
  validates :status, inclusion: { in: %w(queued) }
end
