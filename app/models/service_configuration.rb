class ServiceConfiguration < ApplicationRecord
  validates :name, :value, :service_id, :deployment_environment, presence: true
  validates :deployment_environment, inclusion: {
    in: Rails.application.config.deployment_environments
  }

  validates :name, uniqueness: {
    scope: [:service_id, :deployment_environment],
    case_sensitive: false
  }
end
