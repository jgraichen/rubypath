require 'spec_helper'

describe Path do
  describe 'Directory Operations' do
    with_backends :mock, :sys do
      describe 'class' do
        describe_method :glob do
          before do
            Path.mock do |root|
              root.mkfile '/file.txt'
              root.mkfile '/lib/path.rb'
              root.mkfile '/lib/path/dir.rb'
              root.mkfile '/lib/path/file.rb'
              root.mkfile '/lib/path/ext.rb'
            end
          end
          subject { lambda{|*args| Path.glob *args } }

          it 'should return matching files (I)' do
            expect(subject.call('/*')).to match_array %w(/file.txt /lib)
          end

          it 'should return matching files (II)' do
            expect(subject.call('/**/*.rb')).to match_array %w(/lib/path.rb /lib/path/dir.rb /lib/path/file.rb /lib/path/ext.rb)
          end

          it 'should return matching files (III)' do
            expect(subject.call('/**/{dir,ext}.rb')).to match_array %w(/lib/path/dir.rb /lib/path/ext.rb)
          end

          it 'should return matching files (IV)' do
            expect(subject.call('/lib/*.rb')).to match_array %w(/lib/path.rb)
          end
        end
      end

      describe '#glob' do
        it 'should delegate to class#glob' do
          expect(Path).to receive(:glob).with('/abc\[\]/.\*\{\}/file/**/{a,b}.rb', 10).and_return([])
          Path('/abc[]/.*{}/file').glob('**/{a,b}.rb', 10)
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
            before { expect(dir.parent).to_not be_existent }
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
        before { expect(dir.parent).to_not be_existent }
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
