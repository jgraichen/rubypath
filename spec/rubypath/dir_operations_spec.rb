require 'spec_helper'

describe Path do
  describe 'Directory Operations' do
    with_backends :mock, :sys do
      describe '#glob' do
        before do
          Path.mock do |root|
            root.touch '/file.txt'
            root.touch '/lib/path.rb'
            root.touch '/lib/path/dir.rb'
            root.touch '/lib/path/file.rb'
          end
        end
      end

      describe '#mkdir' do
        context 'w/o arg' do
          let(:dir) { Path '/dir' }
          before { expect(dir).to_not be_existent }
          subject { dir.mkdir }

          it 'should create directory' do
            expect(subject).to be_directory
          end

          it 'should return path to directory' do
            expect(subject).to eq '/dir'
          end

          it { should be_a Path }

          context 'in non-existent parent directory' do
            let(:dir) { Path '/non-ext/dir' }
            before { expect(dir).to_not be_existent }
            before { expect(dir.dir).to_not be_existent }
            subject { dir.mkdir }

            it 'should raise some error' do
              expect{ subject }.to raise_error(Errno::ENOENT, "No such file or directory - /non-ext/dir")
            end
          end
        end

        context 'with arg' do
          let(:dir)  { Path '/' }
          let(:args) { ['fuu'] }
          before { expect(dir.join(*args)).to_not be_existent }
          subject { dir.mkdir *args }

          it 'should create directory' do
            expect(subject).to be_directory
          end

          it 'should return path to directory' do
            expect(subject).to eq '/fuu'
          end

          it { should be_a Path }
        end
      end

      describe_method :mkpath, aliases: [:mkdir_p] do
        let(:dir) { Path '/path/to/dir' }
        before { expect(dir).to_not be_existent }
        before { expect(dir.dir).to_not be_existent }
        subject { dir.send(described_method) }

        it 'should create directories' do
          expect(subject).to be_directory
        end

        it 'should return path to directory' do
          expect(subject).to eq '/path/to/dir'
        end

        it { should be_a Path }
      end

      describe_method :entries do
        let(:path) { Path '/' }
        let(:args) { Array.new }
        subject { path.send described_method, *args }

        context 'with directory with children' do
          before do
            path.touch 'file.a'
            path.touch 'file.b'
            path.mkdir 'dir.a'
            path.mkdir 'dir.b'
          end

          it 'should list of entries' do
            expect(subject).to match_array %w(.. . file.a file.b dir.a dir.b)
          end

          it 'should return list of Path objects' do
            subject.each{|e| expect(e).to be_a Path }
          end
        end

        context 'with non-existent directory' do
          let(:path) { Path '/non-existent-dir' }

          it 'should raise error' do
            expect { subject }.to raise_error(Errno::ENOENT, "No such file or directory - /non-existent-dir")
          end
        end
      end
    end
  end
end
