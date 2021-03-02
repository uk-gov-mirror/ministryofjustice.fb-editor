describe AssertedIdentity do
  subject(:asserted_identity) { described_class }

  describe '#from_auth0_userinfo' do
    context 'no name in claims' do
      let(:user_info) do
        {
          'info' => {
            'uuid' => SecureRandom.uuid,
            'provider' => 'provider',
            'email' => email_address
          }
        }
      end

      context 'two names in email address' do
        let(:email_address) { 'riri.williams@stark-industries.com' }

        it 'uses the email to create the name' do
          expect(subject.from_auth0_userinfo(user_info).name).to eq('Riri Williams')
        end
      end

      context 'more than two names in email address' do
        let(:email_address) { 'jean.luc.picard@ncc1701d.com' }

        it 'uses the email to create the name' do
          expect(subject.from_auth0_userinfo(user_info).name).to eq('Jean Luc Picard')
        end
      end
    end

    context 'with a name in the claims' do
      let(:user_info) do
        {
          'info' => {
            'uuid' => SecureRandom.uuid,
            'provider' => 'provider',
            'name' => 'The Fonz',
            'email' => 'arthur.fonzarelli@happy-days.com'
          }
        }
      end

      it 'uses the name from the claims' do
        expect(subject.from_auth0_userinfo(user_info).name).to eq('The Fonz')
      end
    end
  end
end
