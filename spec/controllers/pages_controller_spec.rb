RSpec.describe PagesController do
  describe '#page_update_params' do
    let(:page) { service.find_page_by_url('/name') }
    before do
      controller.instance_variable_set(:@page, page)
      allow(controller).to receive(:params).and_return(
        ActionController::Parameters.new(page: params)
      )
      allow(controller).to receive(:service_metadata).and_return(service_metadata)
    end

    context 'when components are present' do
      let(:component_params_one) do
        {
          'items' => [
            { 'value' => 'Yes' },
            { 'value' => 'No' }
          ]
        }
      end
      let(:component_params_two) do
        {
          'items' => [
            { 'value' => 'Star Wars' },
            { 'value' => 'Star Trek' }
          ]
        }
      end
      let(:params) do
        {
          components: {
            '0' => JSON.dump(component_params_one),
            '1' => JSON.dump(component_params_two)
          }
        }
      end

      it 'parses components as json' do
        expect(controller.page_update_params).to eq({
          'id' => page.id,
          'latest_metadata' => service_metadata,
          'components' => [component_params_one, component_params_two],
          'service_id' => service.service_id
        })
      end
    end

    context 'when components are not present' do
      let(:params) { { heading: 'They are taking the Hobbits to Isengard' } }

      it 'parses params' do
        expect(controller.page_update_params).to eq({
          'id' => page.id,
          'latest_metadata' => service_metadata,
          'service_id' => service.service_id,
          'heading' => 'They are taking the Hobbits to Isengard'
        })
      end
    end
  end
end
