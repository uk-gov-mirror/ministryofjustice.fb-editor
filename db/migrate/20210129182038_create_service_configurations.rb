class CreateServiceConfigurations < ActiveRecord::Migration[6.1]
  def change
    create_table :service_configurations do |t|
      t.string :name, null: false
      t.string :value, null: false
      t.string :deployment_environment, null: false
      t.uuid :service_id

      t.timestamps
    end
    add_index :service_configurations, :service_id
    add_index :service_configurations, [:service_id, :deployment_environment],
      name: 'index_service_configurations_on_service_id_and_deployment_env'
  end
end
