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

          it 'should return file content' do
            expect(subject).to eq 'CONTENT'
          end

          context 'with read length and offset' do
            let(:args) { [4, 2] }

            it 'should return part of content' do
              expect(subject).to eq 'NTEN'
            end

            context 'with oversized length' do
              let(:args) { [10, 2] }

              it 'should return part of content' do
                expect(subject).to eq 'NTENT'
              end
            end

            context 'with oversized offset' do
              let(:args) { [10, 10] }

              it 'should return part of content' do
                expect(subject).to eq nil
              end
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
          let(:expected_content) { 'CONTENT' }

          it_behaves_like '#write'

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
        end
      end

    end
  end
end
