require 'spec_helper'

describe Path do
  describe 'Comparison' do
    let(:path) { Path.new '/path/to/file' }

    describe_method :eql?, aliases: [:==] do
      context 'with Path object' do
        it 'should compare paths (1)' do
          res = path.send described_method, Path('/path/to/file')
          expect(res).to be true
        end

        it 'should compare paths (2)' do
          res = path.send described_method, Path('/path/to/another/file')
          expect(res).to be false
        end

        it 'should compare clean paths (1)' do
          res = path.send described_method, Path('/path/to/./file')
          expect(res).to be true
        end

        it 'should compare clean paths (2)' do
          res = path.send described_method, Path('/path/to/another/../file')
          expect(res).to be true
        end
      end

      context 'with String object' do
        it 'should compare paths (1)' do
          res = path.send described_method, '/path/to/file'
          expect(res).to be true
        end

        it 'should compare paths (1)' do
          res = path.send described_method, '/path/to/another/file'
          expect(res).to be false
        end

        it 'should compare clean paths (1)' do
          res = path.send described_method, '/path/to/./file'
          expect(res).to be true
        end

        it 'should compare clean paths (2)' do
          res = path.send described_method, '/path/to/another/../file'
          expect(res).to be true
        end
      end

      context 'with Pathname object' do
        it 'should compare paths (1)' do
          res = path.send described_method, Pathname.new('/path/to/file')
          expect(res).to be true
        end

        it 'should compare paths (1)' do
          res = path.send described_method,
                          Pathname.new('/path/to/another/file')
          expect(res).to be false
        end

        it 'should compare clean paths (1)' do
          res = path.send described_method, Pathname.new('/path/to/./file')
          expect(res).to be true
        end

        it 'should compare clean paths (2)' do
          res = path.send described_method,
                          Pathname.new('/path/to/another/../file')
          expect(res).to be true
        end
      end
    end
  end
end
