require 'spec_helper'

describe Path do
  describe 'File Operations' do
    with_backends :mock, :sys do
      let(:path) { Path('/path/to/file.txt') }

      describe_method :name, aliases: [:basename] do
        subject { path.send described_method }

        it 'should return file name' do
          should eq 'file.txt'
        end
      end

      describe_method :touch do
        let(:path) { Path '/rubypath' }
        let(:args) { Array.new }
        let(:expected_path) { path }
        subject { path.touch *args }
        before { expect(path).to_not be_existent }

        shared_examples '#touch' do
          it 'should create file' do
            subject
            expect(expected_path).to be_existent
          end

          it 'should update modification time' do
            subject
            expect(expected_path.mtime).to be_within(1).of(Time.now)
          end
        end

        shared_examples '#touch with existing file' do
          before do
            expected_path.write 'ABC'
            expected_path.mtime = Time.now - 3600
          end
          before { expect(expected_path.mtime).to be < (Time.now - 30) }

          it_behaves_like "#touch"

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
          before { path.dir.write 'ABC' }

          it 'should raise ENOTDIR error' do
            expect { subject }.to raise_error(Errno::ENOTDIR, "Not a directory - /rubypath/file")
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
            expect(path.mtime).to be_within(1).of(Time.now)
          end
        end

        context 'with file in non-existent directory' do
          let(:path) { Path '/dir/file' }

          it 'should raise ENOENT error' do
            expect{ subject }.to raise_error(Errno::ENOENT, "No such file or directory - /dir/file")
          end
        end
      end

      describe_method :mkfile do
        let(:path) { Path '/path/to/file.txt' }
        let(:args) { Array.new }
        let(:expected_path) { path.dup }
        subject { path.send described_method, *args }

        shared_examples '#mkfile' do
          it 'should create all missing directories' do
            expect{ subject }.to change{ expected_path.dir.directory? }.from(false).to(true)
          end

          it 'should create file' do
            expect{ subject }.to change{ expected_path.file? }.from(false).to(true)
          end
        end

        it_behaves_like '#mkfile'

        context 'with args' do
          let(:args) { %w(sub file) }
          let(:expected_path) { Path '/path/to/file.txt/sub/file'}

          it_behaves_like '#mkfile'
        end

        context 'with existing directory' do
          before { path.mkpath }

          it 'should raise ENOENT error' do
            expect{ subject }.to raise_error(Errno::ENOENT, "No such file or directory - /path/to/file.txt")
          end
        end

        context 'with existing file in path' do
          before { path.dir.dir.mkpath; path.dir.touch }

          it 'should raise EISDIR error' do
            expect{ subject }.to raise_error(Errno::ENOTDIR, "Not a directory - /path/to/file.txt")
          end
        end

        context 'with absolute root dir as path' do
          let(:path) { Path '/' }

          it 'should raise EISDIR error' do
            expect{ subject }.to raise_error(Errno::ENOENT, "No such file or directory - /")
          end
        end
      end

      describe_method :lookup do
        let(:path) { Path('~') }
        before do
          Path.mock do |r|
            path.mkpath 'a/b/c/d'
            path.touch 'a/test.txt'
            path.touch 'a/b/c/config.yaml'
            path.touch 'a/b/.config.yml'
            path.touch 'a/config.yml'
          end
        end
        before { expect(path.join('a/b/c/d')).to be_directory }

        context "with filename" do
          it "should find file in current directory" do
            expect(path.join('a').send(described_method, "test.txt")).to eq path.join('a/test.txt').expand
          end

          it "should find file in parent directory" do
            expect(path.join(%w(a b)).send(described_method, "test.txt")).to eq path.join('a/test.txt').expand
          end

          it "should find file in ancestor directory" do
            expect(path.join("a/b/c/d").send(described_method, "test.txt")).to eq path.join('a/test.txt').expand
          end

          it "should find first file in ancestor directory" do
            expect(path.join("a/b/c/d").send(described_method, "config.yaml")).to eq path.join('a/b/c/config.yaml').expand
          end
        end

        context "with glob" do
          it "should find file in current directory" do
            expect(path.join('a').send(described_method, 'test.*')).to eq path.join('a/test.txt').expand
          end

          it "should find file in parent directory" do
            expect(path.join("a/b").send(described_method, 'test.*')).to eq path.join('a/test.txt').expand
          end

          it "should find file in ancestor directory" do
            expect(path.join("a/b/c/d").send(described_method, 'test.*')).to eq path.join('a/test.txt').expand
          end

          it "should find first file in ancestor directory" do
            expect(path.join("a/b/c/d").send(described_method, 'config.*')).to eq path.join('a/b/c/config.yaml').expand
          end

          it "should find first file that match (I)" do
            expect(path.join("a/b").send(described_method, '*.yml')).to eq path.join('a/config.yml').expand
          end

          it "should find first file that match (II)" do
            expect(path.join("a/b").send(described_method, 'config.{yml,yaml}')).to eq path.join('a/config.yml').expand
          end

          it "should find first file that dotmatch" do
            expect(path.join("a/b").send(described_method, '*.yml', ::File::FNM_DOTMATCH)).to eq path.join('a/b/.config.yml').expand
          end
        end

        context "with regexp" do
          it "should find file in current directory" do
            expect(path.join('a').send(described_method, /^test\.txt$/)).to eq path.join('a/test.txt').expand
          end

          it "should find file in parent directory" do
            expect(path.join("a/b").send(described_method, /^test\.txt$/)).to eq path.join('a/test.txt').expand
          end

          it "should find file in ancestor directory" do
            expect(path.join("a/b/c/d").send(described_method, /^test\.txt$/)).to eq path.join('a/test.txt').expand
          end

          it "should find first file in ancestor directory" do
            expect(path.join("a/b/c/d").send(described_method, /^config\.yaml$/)).to eq path.join('a/b/c/config.yaml').expand
          end

          it "should find first file that match" do
            expect(path.join("a/b").send(described_method, /^config\.ya?ml$/)).to eq path.join('a/config.yml').expand
          end
        end
      end

    end
  end
end
