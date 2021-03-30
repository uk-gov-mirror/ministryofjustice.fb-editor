class MetricsController < ActionController::Base
  def show
    response.set_header('Content-Type', 'text/plain; version=0.0.4')
    @stats = [
      delayed_jobs_stats,
      users_stats,
      active_sessions_stats
    ].flatten

    render 'metrics/show.text'
  end

  def filter_to_string(filter)
    return '' if filter.blank?

    filter.to_a.map { |k, v| "#{k}=\"#{v}\"" }.join(',').prepend('{').concat('}')
  end
  helper_method :filter_to_string

private

  def delayed_jobs_stats
    pending_job_count = Delayed::Job.where('attempts = 0').count
    failed_job_count = Delayed::Job.where('attempts > 0').count

    [
      { name: :delayed_jobs_pending,
        type: 'gauge',
        docstring: 'Number of pending jobs',
        value: pending_job_count },
      {
        name: :delayed_jobs_failed,
        type: 'gauge',
        docstring: 'Number of jobs failed',
        value: failed_job_count
      }
    ]
  end

  def users_stats
    {
      name: :users,
      type: 'counter',
      docstring: 'Number of registered users',
      value: User.count
    }
  end

  def active_sessions_stats
    cutoff_period = 90.minutes.ago
    count = ActiveRecord::SessionStore::Session.where(
      'updated_at < ?', cutoff_period
    ).count

    {
      name: :active_sessions,
      type: 'counter',
      docstring: 'Number of active sessions',
      value: count
    }
  end
end
