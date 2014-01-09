require 'spec_helper'

describe Path do
  describe 'Comparison' do
    let(:path) { Path.new '/path/to/file' }

    describe_method :eql?, aliases: [:==] do
      context 'with Path object' do
        it 'should compare paths (1)' do
          expect(path.send(mth, described_class.new('/path/to/file'))).to eq true
        end

        it 'should compare paths (1)' do
          expect(path.send(mth, described_class.new('/path/to/another/file'))).to eq false
        end
      end

      context 'with String object' do
        it 'should compare paths (1)' do
          expect(path.send(mth, '/path/to/file')).to eq true
        end

        it 'should compare paths (1)' do
          expect(path.send(mth, '/path/to/another/file')).to eq false
        end
      end

      context 'with Pathname object' do
        it 'should compare paths (1)' do
          expect(path.send(mth, Pathname.new('/path/to/file'))).to eq true
        end

        it 'should compare paths (1)' do
          expect(path.send(mth, Pathname.new('/path/to/another/file'))).to eq false
        end
      end
    end
  end
end
