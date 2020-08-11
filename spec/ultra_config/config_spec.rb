require "spec_helper"

RSpec.describe UltraConfig::Config do
  let(:validation_script) { Proc.new {} }
  let(:default) { { default: :old } }

  describe '#initalize' do
    before(:each) do
      @config = described_class.new(:test, [], default, &validation_script)
    end

    it 'sets the validation block' do
      expect(@config.instance_variable_get(:@config_block)).to eq(validation_script)
    end

    it 'sets the value to the default' do
      expect(@config.instance_variable_get(:@value)).to eq(default[:default])
    end
  end

  describe '#value=' do
    let(:new) { :new }

    before(:each) do
      @config = described_class.new(:test, [], {}, &validation_script)
      allow(@config).to receive(:validate)
      @config.value = new
    end

    it 'sets the value' do
      expect(@config.instance_variable_get(:@value)).to eq(new)
    end
  end
end