class CreateSubmissionSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :submission_settings do |t|
      t.boolean :send_email, default: false
      t.string :deployment_environment
      t.uuid :service_id

      t.timestamps
    end

    add_index :submission_settings, :service_id
    add_index :submission_settings, [:service_id, :deployment_environment],
      name: :submission_settings_id_and_environment
  end
end
