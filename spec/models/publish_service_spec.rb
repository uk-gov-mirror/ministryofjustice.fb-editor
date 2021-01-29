RSpec.describe PublishService, type: :model do
  describe 'validations' do
    context 'deployment environment' do
      it 'allow dev and production' do
        should allow_values('dev', 'production').for(:deployment_environment)
      end

      it 'do not allow enything else' do
        should_not allow_values(
          '', 'something-else', 'staging', 'live', 'test'
        ).for(:deployment_environment)
      end
    end

    context 'status' do
      it 'allow queued and completed' do
        should allow_values(
          'queued',
          'pre_publishing',
          'publishing',
          'post_publishing',
          'completed'
        ).for(:status)
      end

      it 'do not allow enything else' do
        should_not allow_values(
          '', 'something-else'
        ).for(:status)
      end
    end

    context 'service_id' do
      it 'do not allow blank' do
        should_not allow_values('').for(:service_id)
      end
    end
  end
end
