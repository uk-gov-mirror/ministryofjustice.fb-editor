class PublishService < ApplicationRecord
  STATUS = %w(
    queued
    pre_publishing
    publishing
    post_publishing
    completed
  ).freeze

  validates :deployment_environment, :status, :service_id, presence: true
  validates :deployment_environment, inclusion: {
    in: Rails.application.config.deployment_environments
  }
  validates :status, inclusion: { in: STATUS }
end
