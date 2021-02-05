class AddIndexToPublishServices < ActiveRecord::Migration[6.1]
  def change
    add_index :publish_services, :service_id

    add_index :publish_services, [:service_id, :deployment_environment]
    add_index :publish_services,
      [
        :service_id,
        :status,
        :deployment_environment
      ],
      name: 'index_publish_services_on_service_status_deployment'
  end
end
