class AddIndexToServiceConfigurations < ActiveRecord::Migration[6.1]
  def change
    add_index :service_configurations,
      [
        :service_id,
        :deployment_environment,
        :name
      ],
      name: 'index_service_configurations_on_service_deployment_name'
  end
end
