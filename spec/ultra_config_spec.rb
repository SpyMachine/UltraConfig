require 'spec_helper'
require_relative 'support/files/config'

RSpec.describe UltraConfig do
  let(:validation_error) { UltraConfig::Validation::ValidationError }

  describe 'configs' do
    context 'undefined config'
      it 'sets value to nil' do
        expect(ConfigTest.blank).to be_nil
      end

      it 'can be changed' do
        ConfigTest.blank = :new
        expect(ConfigTest.blank).to be(:new)
      end

    context 'default config' do
      it 'returns the default' do
        expect(ConfigTest.default).to be(:value)
      end

      it 'default can be changed' do
        ConfigTest.default = :new
        expect(ConfigTest.default).to be(:new)
      end

      it 'can be changed to any type' do
        ConfigTest.default = 3
        expect(ConfigTest.default).to eq(3)
      end
    end

    context 'validation' do
      context 'one_of validation' do
        it 'does not raise an error if in list' do
          expect { ConfigTest.one_of = :that }.to_not raise_error
        end

        it 'converts strings to symbols if value is symbol' do
          expect { ConfigTest.one_of = 'that' }.to_not raise_error
        end

        it 'converts strings to symbols if value is nil but uses one_of validation with list of symbols' do
          expect { ConfigTest.space1.one_of  = 'that' }.to_not raise_error
          expect(ConfigTest.space1.one_of).to eq(:that)
        end

        it 'does raise an error if not in list' do
          expect { ConfigTest.one_of = :the_other }.to raise_error(validation_error)
        end
      end

      context 'match validation' do
        it 'does not raise an error if matches' do
          expect { ConfigTest.match = 'this2' }.to_not raise_error
        end

        it 'does raise an error if matches' do
          expect { ConfigTest.match = 'that' }.to raise_error(validation_error)
        end
      end

      context 'range validation' do
        it 'does not raise an error if in range' do
          expect { ConfigTest.range = 4 }.to_not raise_error
        end

        it 'does raise an error if out of range' do
          expect { ConfigTest.range = 12 }.to raise_error(validation_error)
        end
      end

      context 'type safety validation' do
        context 'type is weak' do
          it 'does not raise an error' do
            expect { ConfigTest.weak_type = 'string' }.to_not raise_error
          end
        end

        context 'type is strong' do
          context 'class is same' do
            it 'does not raise an error' do
              expect { ConfigTest.strong_type = :sym2 }.to_not raise_error
            end
          end

          context 'class is different' do
            it 'does not raise an error' do
              expect { ConfigTest.strong_type = [:string] }.to raise_error(validation_error)
            end
          end

          context 'class is different but new value is string and old value is symbol' do
            it 'does not raise an error' do
              expect { ConfigTest.strong_type = 'string' }.to_not raise_error
            end
          end
        end
      end

      context 'custom validation' do
        it 'does not raise an error if block returns true' do
          expect { ConfigTest.custom = { this: :that, that: :this } }.to_not raise_error
        end

        it 'does raise an error if block returns false' do
          expect { ConfigTest.custom = { this: :that2 } }.to raise_error(validation_error)
        end
      end
    end
  end

  describe 'namespaces' do
    it 'can have configs in namespace' do
      expect(ConfigTest.space1.default).to eq(:another_value)
    end

    it 'can have other namespace in namespace' do
      expect(ConfigTest.space2.space3.default).to eq(:a_third_value)
    end
  end

  describe 'settings' do
    describe 'type_safety, :strong' do
      before(:all) do
        # TODO this sucks, fix this
        require_relative 'support/files/strongly_typed'
        StronglyTypedTest.blank = :new
      end

      it 'can not change the type unless it\'s nil' do
        expect(StronglyTypedTest.blank).to be(:new)
        expect { StronglyTypedTest.blank = ['new'] }.to raise_error(validation_error)
      end

      it 'booleans can switch boolean type' do
        expect(StronglyTypedTest.boolean).to be(true)
        StronglyTypedTest.boolean = false
        expect(StronglyTypedTest.boolean).to be(false)
      end

      it 'lets configs explicitly choose there type safety' do
        expect { StronglyTypedTest.weak_type = 'string' }.to_not raise_error
      end
    end
  end

  describe 'reset' do
    it 'can be reset' do
      expect(ConfigTest.default).to eq(3)
      ConfigTest.reset
      expect(ConfigTest.default).to eq(:value)
    end
  end
end
