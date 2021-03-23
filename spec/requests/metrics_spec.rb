require 'rails_helper'

RSpec.describe 'MetricsController', type: :request do
  describe 'GET /metrics' do
    before do
      get '/metrics'
    end

    it 'shows the required metrics' do
      expected_response = <<~HEREDOC
      # HELP delayed_jobs_pending Number of pending jobs
      # TYPE delayed_jobs_pending gauge
      delayed_jobs_pending 0
      # HELP delayed_jobs_failed Number of jobs failed
      # TYPE delayed_jobs_failed gauge
      delayed_jobs_failed 0
      # HELP users Number of registered users
      # TYPE users counter
      users 0
      # HELP active_sessions Number of active sessions
      # TYPE active_sessions counter
      active_sessions 0
      HEREDOC

      expect(response.body).to eq(expected_response)
    end
  end
end
