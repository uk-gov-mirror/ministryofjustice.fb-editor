class SubmissionSetting < ApplicationRecord
  validates :service_id, :deployment_environment, presence: true
  validates :deployment_environment, inclusion: {
    in: Rails.application.config.deployment_environments
  }
end
