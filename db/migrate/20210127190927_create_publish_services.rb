class CreatePublishServices < ActiveRecord::Migration[6.1]
  def change
    create_table :publish_services do |t|
      t.string :deployment_environment, null: false
      t.uuid :service_id, null: false
      t.string :status, null: false

      t.timestamps
    end
  end
end
