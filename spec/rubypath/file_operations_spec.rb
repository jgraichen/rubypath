# frozen_string_literal: true
require 'spec_helper'

describe Path do
  let(:delta) { 1.0 }

  describe 'File Operations' do
    with_backends :mock, :sys do
      let(:path) { Path('/path/to/file.txt') }

      describe_method :name, aliases: [:basename] do
        subject { path.send described_method }

        it 'should return file name' do
          should eq 'file.txt'
        end
      end

      describe_method :unlink do
        subject { path.send described_method }

        context 'on non-existent file' do
          it { expect { subject }.to raise_error Errno::ENOENT }
        end

        context 'on existent file' do
          before { path.mkfile }

          it 'should unlink file' do
            expect { subject }.to change(path, :exist?).from(true).to(false)
          end
        end

        context 'on existent directory' do
          before { path.mkpath }

          it { expect { subject }.to raise_error Errno::EISDIR }
        end

        context 'with args' do
          subject { path.send(described_method, 'file') }

          context 'on non-existent file' do
            it { expect { subject }.to raise_error Errno::ENOENT }
          end

          context 'on existent file' do
            before { path.mkfile('file') }

            it 'should unlink file' do
              expect { subject }
                .to change(path.join('file'), :exist?).from(true).to(false)
            end
          end
        end
      end

      describe_method :touch do
        let(:path) { Path '/rubypath' }
        let(:args) { [] }
        let(:expected_path) { path }
        subject { path.touch(*args) }
        before { expect(path).to_not be_existent }

        shared_examples '#touch' do
          it 'should create file' do
            subject
            expect(expected_path).to be_existent
          end

          it 'should update modification time' do
            subject
            expect(expected_path.mtime).to be_within(delta).of(Time.now)
          end
        end

        shared_examples '#touch with existing file' do
          before do
            expected_path.write 'ABC'
            expected_path.mtime = Time.now - 3600
          end
          before { expect(expected_path.mtime).to be < (Time.now - 30) }

          it_behaves_like '#touch'

          it 'should not change content' do
            subject
            expect(expected_path.read).to eq 'ABC'
          end
        end

        it_behaves_like '#touch with existing file'

        context 'with args' do
          let(:args) { '../file' }
          let(:expected_path) { Path '/file' }

          it_behaves_like '#touch with existing file'
        end

        context 'with existing file in path' do
          let(:path) { super().join('file') }
          before { path.parent.write 'ABC' }

          it 'should raise ENOTDIR error' do
            expect { subject }.to raise_error(
              Errno::ENOTDIR, 'Not a directory - /rubypath/file'
            )
          end
        end

        context 'with existing directory' do
          before do
            path.mkdir
            path.mtime = Time.now - 3600
          end
          before { expect(path).to be_directory }
          before { expect(path.mtime).to be < (Time.now - 30) }

          it 'should should update modification time' do
            subject
            expect(path.mtime).to be_within(delta).of(Time.now)
          end
        end

        context 'with file in non-existent directory' do
          let(:path) { Path '/dir/file' }

          it 'should raise ENOENT error' do
            expect { subject }.to raise_error(
              Errno::ENOENT, 'No such file or directory - /dir/file'
            )
          end
        end
      end

      describe_method :mkfile do
        let(:path) { Path '/path/to/file.txt' }
        let(:args) { [] }
        let(:expected_path) { path.dup }
        subject { path.send described_method, *args }

        shared_examples '#mkfile' do
          it 'should create all missing directories' do
            expect { subject }.to change { expected_path.parent.directory? }
              .from(false).to(true)
          end

          it 'should create file' do
            expect { subject }.to change { expected_path.file? }
              .from(false).to(true)
          end
        end

        it_behaves_like '#mkfile'

        context 'with args' do
          let(:args) { %w(sub file) }
          let(:expected_path) { Path '/path/to/file.txt/sub/file' }

          it_behaves_like '#mkfile'
        end

        context 'with existing directory' do
          before { path.mkpath }

          it 'should raise ENOENT error' do
            expect { subject }.to raise_error(
              Errno::ENOENT, 'No such file or directory - /path/to/file.txt'
            )
          end
        end

        context 'with existing file in path' do
          before do
            path.parent.parent.mkpath
            path.parent.touch
          end

          it 'should raise EISDIR error' do
            expect { subject }.to raise_error(
              Errno::ENOTDIR, 'Not a directory - /path/to/file.txt'
            )
          end
        end

        context 'with absolute root dir as path' do
          let(:path) { Path '/' }

          it 'should raise EISDIR error' do
            expect { subject }.to raise_error(
              Errno::ENOENT, 'No such file or directory - /'
            )
          end
        end
      end

      describe_method :lookup do
        let(:path) { Path('~') }
        before do
          Path.mock do |_r|
            path.mkpath 'a/b/c/d'
            path.touch 'a/test.txt'
            path.touch 'a/b/c/config.yaml'
            path.touch 'a/b/.config.yml'
            path.touch 'a/config.yml'
          end
        end
        before { expect(path.join('a/b/c/d')).to be_directory }

        context 'with filename' do
          it 'should find file in current directory' do
            expect(path.join('a').send(described_method, 'test.txt'))
              .to eq path.join('a/test.txt').expand
          end

          it 'should find file in parent directory' do
            expect(path.join(%w(a b)).send(described_method, 'test.txt'))
              .to eq path.join('a/test.txt').expand
          end

          it 'should find file in ancestor directory' do
            expect(path.join('a/b/c/d').send(described_method, 'test.txt'))
              .to eq path.join('a/test.txt').expand
          end

          it 'should find first file in ancestor directory' do
            expect(path.join('a/b/c/d').send(described_method, 'config.yaml'))
              .to eq path.join('a/b/c/config.yaml').expand
          end
        end

        context 'with glob' do
          it 'should find file in current directory' do
            expect(path.join('a').send(described_method, 'test.*'))
              .to eq path.join('a/test.txt').expand
          end

          it 'should find file in parent directory' do
            expect(path.join('a/b').send(described_method, 'test.*'))
              .to eq path.join('a/test.txt').expand
          end

          it 'should find file in ancestor directory' do
            expect(path.join('a/b/c/d').send(described_method, 'test.*'))
              .to eq path.join('a/test.txt').expand
          end

          it 'should find first file in ancestor directory' do
            expect(path.join('a/b/c/d').send(described_method, 'config.*'))
              .to eq path.join('a/b/c/config.yaml').expand
          end

          it 'should find first file that match (I)' do
            expect(path.join('a/b').send(described_method, '*.yml'))
              .to eq path.join('a/config.yml').expand
          end

          if defined?(::File::FNM_EXTGLOB)
            it 'should find first file that match (II)' do
              expect(path.join('a/b')
                .send(described_method, 'config.{yml,yaml}'))
                .to eq path.join('a/config.yml').expand
            end
          end

          it 'should find first file that dotmatch' do
            expect(path.join('a/b')
              .send(described_method, '*.yml', ::File::FNM_DOTMATCH))
              .to eq path.join('a/b/.config.yml').expand
          end
        end

        context 'with regexp' do
          it 'should find file in current directory' do
            expect(path.join('a').send(described_method, /^test\.txt$/))
              .to eq path.join('a/test.txt').expand
          end

          it 'should find file in parent directory' do
            expect(path.join('a/b').send(described_method, /^test\.txt$/))
              .to eq path.join('a/test.txt').expand
          end

          it 'should find file in ancestor directory' do
            expect(path.join('a/b/c/d').send(described_method, /^test\.txt$/))
              .to eq path.join('a/test.txt').expand
          end

          it 'should find first file in ancestor directory' do
            expect(path.join('a/b/c/d')
              .send(described_method, /^config\.yaml$/))
              .to eq path.join('a/b/c/config.yaml').expand
          end

          it 'should find first file that match' do
            expect(path.join('a/b').send(described_method, /^config\.ya?ml$/))
              .to eq path.join('a/config.yml').expand
          end
        end
      end

      describe_method :mtime do
        let(:path) { Path '/file.txt' }
        before { path.touch }
        subject { path.send described_method }

        it 'should return file modification time' do
          should be_within(delta).of(Time.now)
        end

        context 'with modification time changed' do
          before { path.mtime = Time.new(2175, 12, 24, 18, 0o0, 30) }

          it 'should return file modification time' do
            should eq Time.new(2175, 12, 24, 18, 0o0, 30)
          end
        end
      end

      describe_method :mtime= do
        let(:path) { Path '/file.txt' }
        before { path.touch }
        subject { path.send described_method, Time.new(2175, 12, 24, 18, 0o0, 30) }

        it 'should change file modification time' do
          expect { subject }.to change { path.mtime }.to Time.new(2175, 12, 24, 18, 0o0, 30)
        end
      end

      describe_method :atime do
        let(:path) { Path '/file.txt' }
        subject { path.send described_method }

        context 'new create file' do
          before { path.touch }

          it { should be_within(delta).of(Time.now) }
        end

        context 'with existing file' do
          before { path.touch }

          context 'older file' do
            before { path.touch }
            before { sleep 0.3 }

            it { should be_within(delta).of(Time.now - 0.3) }
          end

          context 'and changed access time' do
            before { path.atime = Time.new(2175, 12, 24, 18, 0o0, 30) }

            it 'should return file access time' do
              should eq Time.new(2175, 12, 24, 18, 0o0, 30)
            end
          end
        end
      end

      describe_method :atime= do
        let(:path) { Path '/file.txt' }
        before { path.touch }
        subject { path.send described_method, Time.new(2175, 12, 24, 18, 0o0, 30) }

        it 'should change file access time' do
          expect { subject }.to change { path.atime }.to Time.new(2175, 12, 24, 18, 0o0, 30)
        end
      end

      describe_method :mode do
        let(:path) { Path '/file' }
        subject { path.send described_method }

        context 'with file' do
          before { path.touch }
          it { should eq 0o666 - Path.umask }
        end

        context 'with directory' do
          before { path.mkpath }
          it { should eq 0o777 - Path.umask }
        end
      end
    end

    describe 'umask' do
      shared_examples 'umask setter' do
        with_backend :sys do
          it 'should set umask' do
            subject
            expect(File.umask).to eq 0o077
          end
        end

        with_backend :mock do
          it 'should set umask' do
            expect { subject }.to change { Path.umask }.from(0o022).to(0o077)
          end
        end
      end

      describe_method :umask do
        let(:args) { [] }
        subject { Path.send described_method, *args }

        context 'as getter' do
          with_backend :sys do
            it 'should return umask' do
              should eq File.umask
            end
          end

          with_backend :mock do
            it 'should return umask' do
              should eq 0o022
            end
          end
        end

        context 'as setter' do
          let(:args) { [0o077] }
          it_behaves_like 'umask setter'
        end
      end

      describe_method :umask= do
        let(:args) { [0o077] }
        subject { Path.send described_method, *args }
        it_behaves_like 'umask setter'
      end
    end
  end
end
