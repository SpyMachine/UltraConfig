require "spec_helper"

RSpec.describe UltraConfig::Validator do
  subject { described_class }
  let(:validation) { Proc.new {} }

  describe '.validate' do
    before(:each) do
      allow(subject).to receive(:instance_eval) { result }
    end

    context 'validation is nil' do
      it 'will not perform any validation' do
        expect(subject).to_not have_received(:instance_eval)
      end
    end

    context 'value is valid' do
      let(:result) {}

      it 'returns with no errors' do
        expect { subject.validate('', '', &validation) }.to_not raise_error
      end

      it 'sets the test variable to nil' do
        expect(subject.instance_variable_get(:@test_value)).to be_nil
      end
    end

    context 'value is invalid' do
      let(:result) { raise UltraConfig::Validator::ValidationError }

      it 'returns with no errors' do
        expect { subject.validate('', '', &validation) }.to raise_error(UltraConfig::Validator::ValidationError)
      end

      it 'sets the test variable to nil' do
        expect(subject.instance_variable_get(:@test_value)).to be_nil
      end
    end

    context 'checking type safety' do
      let(:result) {}

      before(:each) do
        allow(UltraConfig::Settings).to receive(:type_safety) { type }
        allow(subject).to receive(:type_safety)
        subject.validate('', '')
      end

      context 'type safety is strong' do
        let(:type) { :strong }

        it 'validates the type' do
          expect(subject).to have_received(:type_safety)
        end
      end

      context 'type safety is weak' do
        let(:type) { :weak }

        it 'does not validate the type' do
          expect(subject).to_not have_received(:type_safety)
        end
      end
    end
  end

  describe 'validators' do
    shared_examples_for :valid do
      it 'does not raise an error' do
        expect { subject.send(test, *criteria) }.to_not raise_error
      end
    end

    shared_examples_for :invalid do
      it 'does not raise an error' do
        expect { subject.send(test, *criteria) }.to raise_error(UltraConfig::Validator::ValidationError)
      end
    end

    before(:each) do
      subject.instance_variable_set(:@test_value, value)
    end

    describe '.type' do
      let(:test) { :type_safety }

      context 'old value is nil' do
        let(:value) { :new }
        let(:criteria) { [nil] }

        it_is :valid
      end

      context 'old value has same class as new value' do
        let(:value) { :new }
        let(:criteria) { :old }

        it_is :valid
      end

      context 'old value has different class than new value' do
        let(:value) { :new }
        let(:criteria) { 'old' }

        it_is :invalid
      end

      context 'old value and new value are both booleans' do
        let(:value) { false }
        let(:criteria) { true }

        it_is :valid
      end
    end

    describe '.one_of' do
      let(:test) { :one_of }

      context 'value is part of list' do
        let(:value) { 'value' }
        let(:criteria) { [['value']] }

        it_is :valid
      end

      context 'valid is not part of the list' do
        let(:value) { 'value' }
        let(:criteria) { [['not', 'here']] }

        it_is :invalid
      end
    end

    describe '.match' do
      let(:test) { :match }

      context 'value matches regexp' do
        let(:value) { 'value' }
        let(:criteria) { /value/ }

        it_is :valid
      end

      context 'valid does not match regexp' do
        let(:value) { 'value' }
        let(:criteria) { /not that/ }

        it_is :invalid
      end
    end

    describe '.range' do
      let(:test) { :range }

      context 'value in range' do
        let(:value) { 5 }
        let(:criteria) { [1, 10] }

        it_is :valid
      end

      context 'value at lower limit' do
        let(:value) { 1 }
        let(:criteria) { [1, 6] }

        it_is :valid
      end

      context 'value at upper limit' do
        let(:value) { 6 }
        let(:criteria) { [1, 6] }

        it_is :valid
      end

      context 'valid below range' do
        let(:value) { 1 }
        let(:criteria) { [3, 6] }

        it_is :invalid
      end
    end
  end
end