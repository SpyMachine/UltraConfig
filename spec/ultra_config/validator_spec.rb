require "spec_helper"

RSpec.describe UltraConfig::Validation do
  subject { UltraConfig::Config.new(:test, []) }
  let(:validation) { Proc.new {} }
  let(:block) {}
  let(:old_value) {}
  let(:validation_error) { UltraConfig::Validation::ValidationError }

  shared_examples_for :valid do
    it 'does not raise an error' do
      expect { subject.send(test, *criteria, &block) }.to_not raise_error
    end
  end

  shared_examples_for :invalid do
    it 'does not raise an error' do
      expect { subject.send(test, *criteria, &block) }.to raise_error(validation_error)
    end
  end

  before(:each) do
    subject.instance_variable_set(:@intermediate_value, value)
    subject.instance_variable_set(:@value, old_value)
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
      let(:old_value) { 'old' }
      let(:criteria) { :strong }

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

  describe '.custom' do
    let(:test) { :custom }

    context 'valid' do
      let(:value) { 2 }
      let(:criteria) {}
      let(:block) { Proc.new { |value| value % 2 == 0 } }

      it_is :valid
    end
  end
end