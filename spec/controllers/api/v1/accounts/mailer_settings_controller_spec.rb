require 'rails_helper'

RSpec.describe Api::V1::Accounts::MailerSettingsController do
  subject(:overrides) do
    controller = described_class.new
    controller.params = ActionController::Parameters.new(settings: settings)
    controller.send(:test_overrides)
  end

  context 'with copy-pasted values' do
    let(:settings) do
      { address: ' smtp.test ', port: '587', user_name: ' user ', authentication: 'plain', enable_starttls_auto: 'false', ssl: 'true' }
    end

    it 'trims strings and casts port, authentication and booleans' do
      expect(overrides).to eq(address: 'smtp.test', port: 587, user_name: 'user', authentication: :plain,
                              enable_starttls_auto: false, ssl: true)
    end
  end

  context 'with only some keys' do
    let(:settings) { { address: 'smtp.test' } }

    it 'does not add the missing ones' do
      expect(overrides).to eq(address: 'smtp.test')
    end
  end

  context 'without settings' do
    let(:settings) { nil }

    it { is_expected.to eq({}) }
  end
end
