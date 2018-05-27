require "spec_helper"

RSpec.describe UltraConfig::Config do
  let(:validation_script) { Proc.new {} }
  let(:default) { :old }

  describe '#initalize' do
    before(:each) do
      @config = described_class.new(default, &validation_script)
    end

    it 'sets the validation block' do
      expect(@config.instance_variable_get(:@validation)).to eq(validation_script)
    end

    it 'sets the value to the default' do
      expect(@config.instance_variable_get(:@value)).to eq(default)
    end
  end

  describe '#value=' do
    let(:new) { :new }

    before(:each) do
      @config = described_class.new(default, &validation_script)
      allow(@config).to receive(:validate)
      @config.value = new
    end

    it 'performs validation' do
      expect(@config).to have_received(:validate)
    end

    it 'sets the value' do
      expect(@config.instance_variable_get(:@value)).to eq(new)
    end
  end

  describe '#validate' do
    it 'validates the new value' do
      @config = described_class.new(default, &validation_script)
      allow(UltraConfig::Validator).to receive(:validate)
      @config.validate(:new)
      expect(UltraConfig::Validator).to have_received(:validate).with(default, :new, &validation_script)
    end
  end
end