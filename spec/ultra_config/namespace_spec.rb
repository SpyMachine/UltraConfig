require "spec_helper"

RSpec.describe UltraConfig::Namespace do
  let(:block) { Proc.new {} }

  describe '#initialize' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:reset)
      @namespace = described_class.new(&block)
    end

    it 'sets the configuration block' do
      expect(@namespace.instance_variable_get(:@configuration)).to eq(block)
    end

    it 'calls reset' do
      expect(@namespace).to have_received(:reset)
    end
  end

  describe '#namespace' do
    it 'adds a new Namespace object to self\'s objects' do
      @namespace = described_class.new(&block)
      @namespace.namespace(:name, &block)
      expect(@namespace.instance_variable_get(:@objects).size).to eq(1)
      expect(@namespace.instance_variable_get(:@objects)).to have_key(:name)
      expect(@namespace.instance_variable_get(:@objects)[:name]).to be_an_instance_of(UltraConfig::Namespace)
    end
  end

  describe '#config' do
    it 'adds a new Config object to self\'s objects' do
      @namespace = described_class.new(&block)
      @namespace.config(:name, &block)
      expect(@namespace.instance_variable_get(:@objects).size).to eq(1)
      expect(@namespace.instance_variable_get(:@objects)).to have_key(:name)
      expect(@namespace.instance_variable_get(:@objects)[:name]).to be_an_instance_of(UltraConfig::Config)
    end
  end

  describe '#method_missing' do
    context 'message is a config' do
      context 'message is to set value (=)' do
        before(:each) do
          @namespace = described_class.new(&block)
          @namespace.config(:config, &block)
          allow_any_instance_of(UltraConfig::Config).to receive(:value=)
        end

        it 'calls the value= method of the config' do
          expect_any_instance_of(UltraConfig::Config).to receive(:value=)
          @namespace.config = :new
        end
      end

      context 'message is to get a value' do
        before(:each) do
          @namespace = described_class.new(&block)
          @namespace.config(:my_config, &block)
          allow_any_instance_of(UltraConfig::Config).to receive(:value)
        end

        it 'calls the value= method of the config' do
          expect_any_instance_of(UltraConfig::Config).to receive(:value)
          @namespace.my_config
        end
      end
    end

    context 'message is a namespace' do
      before(:each) do
        @namespace = described_class.new(&block)
        @namespace.namespace(:my_namespace, &block)
      end

      it 'gets the namespace' do
        expect(@namespace.my_namespace).to be_a(UltraConfig::Namespace)
      end
    end

    describe '#reset' do
      before(:each) do
        @namespace = described_class.new(&block)
        allow(@namespace).to receive(:instance_eval)
        @namespace.reset
      end

      it 'sets its objects to an empty array' do
        expect(@namespace.instance_variable_get(:@objects)).to eq({})
      end

      it 'runs the given block on itself' do
        expect(@namespace).to have_received(:instance_eval)
      end
    end
  end
end