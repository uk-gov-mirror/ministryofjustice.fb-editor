require 'rails_helper'

RSpec.describe ServiceConfiguration, type: :model do
  describe '#valid?' do
    context 'service_id' do
      it 'do not allow blank' do
        should_not allow_values('').for(:service_id)
      end
    end

    context 'name' do
      it 'do not allow blank' do
        should_not allow_values('').for(:name)
      end
    end

    context 'value' do
      it 'do not allow blank' do
        should_not allow_values('').for(:value)
      end
    end

    context 'deployment environment' do
      it 'allow dev and production' do
        should allow_values('dev', 'production').for(:deployment_environment)
      end

      it 'do not allow enything else' do
        should_not allow_values(
          nil, '', 'something-else', 'staging', 'live', 'test'
        ).for(:deployment_environment)
      end
    end
  end
end
