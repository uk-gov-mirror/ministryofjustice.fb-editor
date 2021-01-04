require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { User.create!(name: 'test user', email: 'test@example.com') }

  describe 'has_identity?' do
    let(:identity) { Identity.new(uid: 'myuid', provider: 'myprovider') }

    context 'when no identity exists with the given uid & provider' do
      it 'returns false' do
        expect(user.has_identity?(identity)).to be(false)
      end
    end

    context 'when an identity exists with the given uid & provider' do
      before do
        user.identities << identity
      end

      it 'returns true' do
        expect(user.has_identity?(identity)).to be(true)
      end
    end
  end
end
