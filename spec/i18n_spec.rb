require 'rails_helper'

RSpec.describe I18n do
  def flatten_keys(hash, prefix = nil)
    hash.flat_map do |key, value|
      path = [prefix, key].compact.join('.')
      value.is_a?(Hash) ? flatten_keys(value, path) : [path]
    end
  end

  it 'supports only English and Spanish, keeping their original database indexes' do
    expect(LANGUAGES_CONFIG.transform_values { |lang| lang[:iso_639_1_code] }).to eq(0 => 'en', 12 => 'es')
    expect(described_class.available_locales).to contain_exactly(:en, :es)
    expect(Account.locales).to eq('en' => 0, 'es' => 12)
  end

  %w[en.yml devise.en.yml].each do |english_file|
    it "has every key of #{english_file} translated to Spanish" do
      spanish_file = english_file.sub('en', 'es')
      english = YAML.load_file(Rails.root.join('config/locales', english_file)).fetch('en')
      spanish = YAML.load_file(Rails.root.join('config/locales', spanish_file)).fetch('es')

      expect(flatten_keys(english) - flatten_keys(spanish)).to be_empty
    end
  end
end
