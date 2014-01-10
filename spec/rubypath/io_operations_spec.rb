require 'spec_helper'

describe Path do
  describe 'IO Operations' do
    with_backends :mock, :sys do

      describe_method :read do
        let(:path) { Path '/file' }
        subject { path.send described_method }

        context 'with existing file' do
          before { path.write 'CONTENT' }

          it 'should return file content' do
            expect(subject).to eq 'CONTENT'
          end
        end

        context 'with existing directory' do
          before { path.mkdir }

          it 'should raise EISDIR error' do
            expect { subject }.to raise_error(Errno::EISDIR, "Is a directory - /file")
          end
        end

        context 'with non-existent file' do
          before { expect(path).to_not be_existent }

          it 'should raise ENOENT error' do
            expect { subject }.to raise_error(Errno::ENOENT, "No such file or directory - /file")
          end
        end
      end

      describe_method :write do
        let(:path) { Path '/file' }
        subject { path.send described_method, 'CONTENT' }
      end

    end
  end
end
