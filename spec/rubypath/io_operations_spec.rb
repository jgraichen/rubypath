require 'spec_helper'

describe Path do
  describe 'IO Operations' do
    with_backends :mock, :sys do

      describe_method :read do
        let(:path) { Path '/file' }
        let(:args) { Array.new }
        subject { path.send described_method, *args }

        context 'with existing file' do
          before { path.write 'CONTENT' }
          before { path.mtime = Time.new(1970) }
          before { path.atime = Time.new(1970) }

          it { should eq 'CONTENT' }

          it 'should update access time' do
            subject
            expect(path.atime).to be_within(0.1).of(Time.now)
          end

          context 'with read length and offset' do
            let(:args) { [4, 2] }

            it { should eq 'NTEN' }

            context 'with oversized length' do
              let(:args) { [10, 2] }
              it { should eq 'NTENT' }
            end

            context 'with oversized offset' do
              let(:args) { [10, 10] }
              it { should eq nil }
            end
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
        let(:args) { Array.new }
        subject { path.send described_method, 'CONTENT', *args }

        shared_examples '#write' do
          it 'should write content' do
            subject
            expect(path.read).to eq expected_content
          end

          it { should be_a Path }
          it { expect(subject.path).to eq path.path}
        end

        context 'with existing file' do
          before { path.touch }
          before { path.mtime = Time.new(1970) }
          before { path.atime = Time.new(1970) }
          let(:expected_content) { 'CONTENT' }

          it_behaves_like '#write'

          it 'should update mtime' do
            expect{ subject }.to change{ path.mtime }
            expect(path.mtime).to be_within(0.1).of(Time.now)
          end

          it 'should not update atime' do
            expect{ subject }.to_not change{ path.atime }
          end

          context 'with offset' do
            before { path.write '12345678901234567890' }
            let(:args) { [4] }
            let(:expected_content) { '1234CONTENT234567890' }

            it_behaves_like '#write'
          end
        end

        context 'with existing directory' do
          before { path.mkdir }

          it 'should write content' do
            expect{ subject }.to raise_error(Errno::EISDIR, "Is a directory - /file")
          end
        end

        context 'with non-existing file' do
          before { expect(path).to_not be_existent }
          let(:expected_content) { 'CONTENT' }

          it_behaves_like '#write'

          it 'should set mtime' do
            subject
            expect(path.mtime).to be_within(0.1).of(Time.now)
          end

          it 'should set atime' do
            subject
            expect(path.atime).to be_within(0.1).of(Time.now)
          end
        end
      end
    end
  end
end
