namespace 'db:sessions' do
  desc "Trim old sessions from the table (> 90 minutes)"
  task :trim => [:environment, 'db:load_config'] do
    cutoff_period = 90.minutes.ago
    ActiveRecord::SessionStore::Session.
    where("updated_at < ?", cutoff_period).
    delete_all
  end
end
