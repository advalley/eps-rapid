require 'spec_helper'

RSpec.describe EpsRapid do
  it "has a version number" do
    expect(EpsRapid::VERSION).not_to be nil
  end

  it 'is possible to provide config options' do
    described_class.configure do |c|
      expect(c).to eq(described_class)
    end
  end

  describe '#configure' do
    let(:fake_class) { class_double('EpsRapid') }

    it 'is possible to set api_key' do
      expect(fake_class).to receive(:api_key=).with('mock-api-key')
      fake_class.api_key = 'mock-api-key'
    end

    it 'is possible to set secret_key' do
      expect(fake_class).to receive(:secret_key=).with('mock-secret-key')
      fake_class.secret_key = 'mock-secret-key'
    end

    it 'is possible to set base_path' do
      expect(fake_class).to receive(:base_path=).with('https://mock.api.com')
      fake_class.base_path = 'https://mock.api.com'
    end

    it 'is possible to set language' do
      expect(fake_class).to receive(:language=).with('en-US')
      fake_class.language = 'en-US'
    end
  end
end